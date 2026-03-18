{ lib
, python3
, fetchFromGitHub
, pkgs
, xdotool
, wtype
, wl-clipboard
, portaudio
, gobject-introspection
, gtk3
, libappindicator-gtk3
, wrapGAppsHook3
, pipewire
, alsa-plugins
, vulkan-headers
, vulkan-loader
, shaderc
}:

let
  pythonPackages = python3.pkgs;

  whisper-cpp-vulkan = pkgs.whisper-cpp.override {
    vulkanSupport = true;
  };

  pynput = pythonPackages.buildPythonPackage rec {
    pname = "pynput";
    version = "1.7.6";
    pyproject = true;
    src = pythonPackages.fetchPypi {
      inherit pname version;
      hash = "sha256-OlcmVG2lQRa2h3hdOLHbVpl84dKOU+jSL8ZW2LkuUzw=";
    };
    postPatch = ''
      substituteInPlace setup.py --replace-fail "'setuptools-lint >=0.5'," "" --replace-fail "'sphinx >=1.3.1'" ""
    '';
    nativeBuildInputs = [ pythonPackages.setuptools ];
    propagatedBuildInputs = with pythonPackages; [ xlib six evdev ];
    doCheck = false;
  };

  # pywhispercpp: Replaced with a wrapper around nixpkgs' whisper-cpp
  pywhispercpp = pythonPackages.buildPythonPackage rec {
    pname = "pywhispercpp";
    version = "0.1";
    pyproject = true;

    src = pkgs.runCommand "pywhispercpp-src" { } ''
      mkdir -p $out/pywhispercpp
      cat > $out/pyproject.toml << 'TOML'
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"
[project]
name = "pywhispercpp"
version = "0.1"
TOML
      cat > $out/pywhispercpp/__init__.py << 'PY'
from pywhispercpp.model import Model
PY
      cat > $out/pywhispercpp/model.py << 'PY'
import subprocess
import tempfile
import struct
import os

class Segment:
    def __init__(self, text):
        self.text = text

class Model:
    def __init__(self, model_path, **kwargs):
        self.model_path = model_path

    def transcribe(self, audio, language=None, **kwargs):
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            tmp_path = f.name
            num_samples = len(audio)
            data = struct.pack("<%df" % num_samples, *audio)
            # Write WAV header (32-bit float, mono, 16kHz)
            f.write(b"RIFF")
            f.write(struct.pack("<I", 36 + len(data)))
            f.write(b"WAVE")
            f.write(b"fmt ")
            f.write(struct.pack("<I", 16))
            f.write(struct.pack("<H", 3))  # IEEE float
            f.write(struct.pack("<H", 1))  # mono
            f.write(struct.pack("<I", 16000))  # sample rate
            f.write(struct.pack("<I", 16000 * 4))  # byte rate
            f.write(struct.pack("<H", 4))  # block align
            f.write(struct.pack("<H", 32))  # bits per sample
            f.write(b"data")
            f.write(struct.pack("<I", len(data)))
            f.write(data)
        try:
            cmd = ["whisper-cli", "--model", self.model_path, "--file", tmp_path, "--no-timestamps"]
            if language:
                cmd.extend(["--language", language])
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            text = result.stdout.strip()
            return [Segment(text)]
        except Exception as e:
            print(f"whisper-cpp error: {e}")
            return [Segment("")]
        finally:
            os.unlink(tmp_path)
PY
    '';

    build-system = [ pythonPackages.setuptools ];
    propagatedBuildInputs = [ whisper-cpp-vulkan pythonPackages.numpy ];
  };

in
pythonPackages.buildPythonApplication rec {
  pname = "vocalinux";
  version = "unstable-2024-03-18";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "jatinkrmalik";
    repo = "vocalinux";
    rev = "b6fb2b838b058b214d723ea4a1660e546d1b9e3b";
    hash = "sha256-QoT5MgmXir4M0sjUq5eNTTJIFL330go6d5uH7Cqoem4=";
  };
  postPatch = ''
    sed -i '/"vosk>=/d' pyproject.toml
    # Also remove pywhispercpp, as we are using a wrapper
    sed -i '/"pywhispercpp>=/d' pyproject.toml
  '';
  nativeBuildInputs = [ wrapGAppsHook3 gobject-introspection pythonPackages.setuptools pythonPackages.wrapPython ];
  buildInputs = [ gtk3 portaudio libappindicator-gtk3 ];
  propagatedBuildInputs = with pythonPackages; [
    pywhispercpp
    pydub
    pynput
    evdev
    pyaudio
    xlib
    pygobject3
    requests
    psutil
    tqdm
  ];
  postInstall = ''
    mkdir -p $out/share/vocalinux
    cp -r $src/resources $out/share/vocalinux/resources
  '';
  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ xdotool wtype wl-clipboard whisper-cpp-vulkan ]}"
    "--set ALSA_PLUGIN_DIR ${pipewire}/lib/alsa-lib"
  ];
  meta = with lib; {
    description = "Voice-to-text for Linux using whisper.cpp";
    homepage = "https://github.com/jatinkrmalik/vocalinux";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
