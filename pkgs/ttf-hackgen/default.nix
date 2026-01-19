{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "ttf-hackgen";
  version = "2.10.0";

  src = fetchzip {
    url = "https://github.com/yuru7/HackGen/releases/download/v${version}/HackGen_NF_v${version}.zip";
    sha256 = "111fjcm0lcb2bfhddpx1503vk12va5j1241dfia9pjs86cirnj4z";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp *.ttf $out/share/fonts/truetype/
  '';

  meta = with stdenv.lib; {
    description = "HackGen - Japanese programming font";
    homepage = "https://github.com/yuru7/HackGen";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
