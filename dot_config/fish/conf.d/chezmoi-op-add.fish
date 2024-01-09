function chezmoi-op-add
  set path $argv
  set path_without_relative_prefix (string replace ~/ "" $path)

  if test -e $path
    # check login status
    if not op whoami
      eval (op signin)
      echo ""
    end

    # create 1password document
    set op_created_res (op document create $path --tags chezmoi --title $path_without_relative_prefix)

    # get uuid from response
    set op_item_uuid (string trim (string split "," (string split -m 1 ":" $op_created_res)[2])[1])

    echo ""
    echo "1password item uuid: $op_item_uuid"
    echo ""
    
    set chezmoi_template_file_content "{{- onepasswordDocument $op_item_uuid -}}"

    # add chezmoi as template file
    set chezmoi_add_res (chezmoi add -v --template $path)

    # get chezmoi item path
    set chezmoi_item_path (echo $chezmoi_add_res | grep -oP '(?<=\+\+\+ b/)[^\s]+')

    # set chezmoi source-path
    set chezmoi_source_path (chezmoi source-path)

    if test -z $chezmoi_item_path
      echo "chezmoi item path is empty"
      echo "set manually following content to $chezmoi_source_path/$path_without_relative_prefix"
      echo ""
      echo $chezmoi_template_file_content
      exit 1
    end

    echo "update content: $chezmoi_source_path/$chezmoi_item_path"
    # replace chezmoi item content
    echo $chezmoi_template_file_content > $chezmoi_source_path/$chezmoi_item_path
  else
    echo "file does not exist"
  end
end

function sample
  echo "sample!"
end
