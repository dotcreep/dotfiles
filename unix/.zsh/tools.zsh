############################## TOOLS ##############################
function termux_tools(){
  if ! $_thisTermux; then _HandleWarn "$_notSupport" && return 1; fi
  function _termux_tools_usage(){
    echo "Usage: termux_tools [options] <path/file>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -b DIR          Backup Termux"
    echo "    -r FILE         Restore Termux"
    echo "    -a FILE_NAME    Create a script on boot"
    echo "    -s              Setup storage"
    echo "    -c              Change repo"
    echo "    -h              Show this message"
    echo "    -R              Install root-repo"
    echo "    -S              Install science-repo"
    echo "    -G              Install game-repo"
    echo "    -X              install X11-repo"
  }
  local BOOT="$HOME/.termux/boot"
  [[ ! -d $BOOT ]] && mkdir -p $BOOT
  while getopts ":b:r:a:scRSGXh" opt; do
    case $opt in
      a ) nano $BOOT/$OPTARG; break;;
      b ) [[ ! -d $OPTARG ]] && _HandleError "Invalid directory" && return 1 && break
          [[ ! $(_found tar) ]] && _checkingPackage -i tar
          _HandleStart "Backup termux"
          local files="$OPTARG/$(date +"%Y-%m-%d_%H:%M").tar.gz"
          local archive=$(tar -zcf $files -C /data/data/com.termux/files ./home ./usr)
          [[ $? -eq 0 && -f $files ]] && _HandleResult "Backup success" || _HandleError "Backup failed"
          break;;
      r ) local checkFiles=$(tar -tf $OPTARG | grep -E '^\.\/(home|usr)\/$')
          [[ ! -f $OPTARG || $? -ne 0 ]] && _HandleError "Invalid file" && return 1 && break
          _HandleStart "Restoring termux data"
          local archive=$(tar -zxf $OPTARG -C /data/data/com.termux/files --recursive-unlink --preserve-permissions)
          [[ $? -eq 0 ]] && _HandleResult "Success restored" || _HandleError "Restore failed"
          break;;
      s ) termux-setup-storage; break;;
      c ) termux-change-repo; break;;
      R ) install root-repo; break;;
      S ) install science-repo; break;;
      G ) install game-repo; break;;
      X ) install x11-repo; break;;
      h ) _termux_tools_usage; return 0;;
      \?) _HandleWarn "Invalid option" >&2; return 1;;
      : ) _HandleError "Option '-$OPTARG' requires a argument" >&2; return 1;;
    esac
  done
  [[ $# -eq 0 ]] && _termux_tools_usage && return 0
}

function dl_tools(){
  [[ ! $(_found wget) ]] && _checkingPackage -i wget
  local directoryDownloads=""
  if $_thisTermux; then
    local directoryDownloads="/sdcard/Download"
    if [[ ! $(_found yt-dlp) ]]; then
      _HandleStart "Installing youtube-dl"
      local process=$(wget -qq https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O $PREFIX/bin/yt-dlp && chmod a+rx $PREFIX/bin/yt-dlp)
      [[ $? -eq 0 && $(_found yt-dlp) ]] && _HandleResult "Success installing youtube-dl" && return 0 || _HandleError "Failed installing youtube-dl" && return 1
    fi
  elif $_thisWin; then
    local getUser=$(powershell.exe /c "& {[System.Environment]::UserName}")
    local User=$(echo $getUser | tr -d '\r')
    local directoryDownloads="/mnt/c/Users/${User}/Downloads"
    if [[ ! $(_found yt-dlp) ]]; then
      _HandleStart "Installing youtube-dl"
      local process=$(sudo wget -qq https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp && sudo chmod a+rx /usr/bin/yt-dlp)
      [[ $? -eq 0 && $(_found yt-dlp) ]] && _HandleResult "Success installing youtube-dl" && return 0 || _HandleError "Failed installing youtube-dl" && return 1
    fi
  elif $_thisLinux; then
    if [[ ! -d "$HOME/Downloads" ]]; then
      mkdir -p "$HOME/Downloads"
      local directoryDownloads="$HOME/Downloads"
    else
      local directoryDownloads="$HOME/Downloads"
    fi
    if [[ ! $(_found yt-dlp) ]]; then
      _HandleStart "Installing youtube-dl"
      local process=$(sudo wget -qq https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/bin/yt-dlp && sudo chmod a+rx /usr/bin/yt-dlp)
      [[ $? -eq 0 && $(_found yt-dlp) ]] && _HandleResult "Success installing youtube-dl" && return 0 || _HandleError "Failed installing youtube-dl" && return 1
    fi
  else
    _HandleWarn "$_notSupport" && return 1
  fi

  function _dl_tools_usage(){
    echo "Usage  : dl_tools [option] URL"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -d      Custom directory"
    echo "    -y      Use yt-dl program"
    echo "    -h      Show this message"
  }
  local custom=""
  local youtube=false
  while getopts ":d:yh" opt; do
    case $opt in
      d ) custom=$OPTARG;;
      y ) youtube=true;;
      : ) _HandleError "Option '-$OPTARG' requires a argument" >&2; break;;
    esac
  done
  [[ -n $custom && ! -d $custom ]] && mkdir -p $custom
  if $youtube; then
    if [[ -z $custom ]]; then
      _HandleStart "Downloading..."
      yt-dlp -q --progress -P "$directoryDownloads" "$@"
    elif [[ -n $custom ]]; then
      _HandleStart "Downloading..."
      yt-dlp -q --progress -P "$custom" "$@"
    fi
  else
    if [[ -z $custom ]]; then
      _HandleStart "Downloading..."
      echo $directoryDownloads
      wget -q --show-progress -P "$directoryDownloads" "$@"
    elif [[ -n $custom ]]; then
      _HandleStart "Downloading..."
      wget -q --show-progress -P "$custom" "$@"
    fi
  fi
}

function git_tools(){
  [[ ! $(_found git) ]] && _checkingPackage -i git
  function _git_tools_usage(){
    echo "Usage: git_tools [options] <path/file>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -p        Git Pull"
    echo "    -P        Git Push"
    echo "    -r        Soft reset commit"
    echo "    -R        Hard reset commit"
    echo "    -l        Git log commit"
    echo "    -s        Create own git server"
    echo "    -w PATH   Working dir for git server"
    echo "    -h        Show this message"
  }
  while getopts ":P:w:r:R:lpsh" opt; do
    case $opt in
      p ) git pull; break;;
      P ) git add . && git commit -m "$OPTARG" && git push; break;;
      s ) git init --bare && break;;
      r ) git reset --soft $OPTARG && break;;
      R ) git reset --hard $OPTARG && break;;
      l ) git log --oneline && break;;
      w ) [[ ! $OPTARG ]] && _HandleWarn "Cancel action.." && return 1
          [[ ! -d "./branches" || ! -d "./hooks" || ! -d "./info" || ! -d "./object" || ! -d "./refs" ]] && \
            _HandleError "GIT Server directory reqired";break
          [[ ! -f "./hooks/post-receive" ]] && touch ./hooks/post-receive && chmod +x ./hooks/post-receive
          [[ ! -d $OPTARG ]] && mkdir -p $OPTARG
          _HandleStart "Add ${GREEN}post-receive${RESET}"
          local post=$(echo -ne "#!/bin/sh\nGIT_WORK_TREE=$OPTARG git checkout -f" >> ./hooks/post-receive)
          [[ $? -eq 0 ]] && _HandleResult "Action success" || _HandleError "Failed writing ${GREEN}post-receive${RESET}"
          break;;
      h ) _git_tools_usage; break;;
      : ) _HandleError "Option -$OPTARG requires an argument" >&2; break;;
      \? ) _HandleError "Invalid option -$OPTARG" >&2; break;;
    esac
  done
}

function image_tools(){
  [[ ! $(_found convert) ]] && _checkingPackage -i imagemagick -p convert
  if [[ ! $(_found cwebp) ]]; then
    local search=$(search webp 2>/dev/null)
    for pkg in "libwebp-tools" "webp"; do
      if [[ $(echo $search | grep "$pkg") ]]; then
        _HandleWarn "cweb not installed. Installing now!"
        _HandleStart "Installing $pkg"
        local installpkg=$(_checkingPackage -i "$pkg" -p cwebp)
        [[ $? -eq 0 ]] && _HandleResult "Success installing $pkg" && break || \
          _HandleError "Failed installing $pkg" && return 1 && break
      else
        _HandleError "$_notSupport" && return 1 && break
      fi
    done
  fi
  [[ ! $(_found potrace) ]] && _checkingPackage -i potrace
  local imageExtension="3fr arw avif bmp cr2 crw cur dcm dcr dds dng \
    erf exr fax fts g3 g4 gif gv hdr heic heif hrz ico iiq ipl \
    jbg jbig jfi jfif jif jnx jp2 jpe jpeg jpg jps k25 kdc mac \
    map mef mng mrw mtv nef nrw orf otb pal palm pam pbm pcd pct \
    pcx pdb pef pes pfm pgm pgx picon pict pix plasma png pnm ppm \
    psd pwp raf ras rgb rgba rgbo rgf rla rle rw2 sct sfw sgi six \
    sixel sr2 srf sun svg tga tiff tim tm2 uyvy viff vips wbmp webp \
    wmz wpg x3f xbm xc xcf xpm xv xwd yuv"
  local compress=false
  function _image_tools_usage(){
    echo "Usage: image_tools [options] <path/file>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -c        Activate compress mode"
    echo "    -s        source file"
    echo "    -t        Target output file"
    echo "                  (not working on compress mode)"
    echo "    -h        Show this message"
  }
  while getopts ":s:t:ch" opt; do
    case $opt in
      s ) local sourceImage=$OPTARG;;
      t ) local target=$OPTARG;;
      c ) local compress=true;;
      h ) _image_tools_usage; return 0;;
      \?) _HandleWarn "Invalid option" >&2; return 1; break;;
      : ) _HandleError "Option '-$OPTARG' requires" >&2; return 1; break;;
    esac
  done
  [[ $# -eq 0 ]] && _image_tools_usage && return 0
  if [[ $imageExtension =~ (^|[[:space:]])$sourceImage($|[[:space:]]) && ! $compress ]]; then
    [[ ! $target =~ '^(webp|jpg|jpeg|png|svg|ico)$' ]] && _HandleError "Invalid target" && return 1
    local allImage=$(find ./ -maxdepth 1 -type f -name "*.$sourceImage" | awk -F'/' '{printf "\"%s\" ", $NF}' | sed 's/,$//')
    [[ -z $allImage ]] && _HandleError "sourceImage image not exists" && return 1
    for images in $allImage; do
      local output="${images%.*}.$target"
      _HandleStart "Convert $images to $output"
      if [[ ${output##*.} == "ico" ]]; then
        local convert=$(convert -resize x16 -gravity center \
          -crop 16x16+0+0 "$iamges" -flatten -colors 256 \
          -background transparent "$output")
      elif [[ ${output##*.} == "svg" ]]; then
        local convert=$(convert "$images" "${images%.*}.ppm" && potrace \
          -s "${images%.*}.ppm" -o "$output" && rm -f "${images%.*}.ppm")
      else
        local convert=$(convert "$images" "$output")
      fi
      [[ $? -eq 0 && -f $output ]] && _HandleResult "Convert '$images' to '$output' success" && \
        return 0 || _HandleError "Failed converting '$images'" && return 1
      break
    done
  elif [[ ! $imageExtension =~ (^|[[:space:]])$sourceImage($|[[:space:]]) && ! $compress ]]; then
    [[ ! -f $sourceImage ]] && _HandleError "sourceImage image not exists" && return 1
    [[ $target =~ '^(webp|jpg|jpeg|png|svg|ico)$' ]] && local output="${sourceImage%.*}.$target" || \
      local output="$target"
    _HandleStart "Convert $sourceImage to $output"
    if [[ ${output##*.} == "ico" ]]; then
      local convert=$(convert -resize x16 -gravity center \
        -crop 16x16+0+0 "$sourceImage" -flatten -colors 256 \
        -background transparent "$output")
    elif [[ ${output##*.} == "svg" ]]; then
      local convert=$(convert "$sourceImage" "${sourceImage%.*}.ppm" && potrace \
        -s "${sourceImage%.*}.ppm" -o "$output" && rm -f "${images%.*}.ppm")
    else
      local convert=$(convert "$sourceImage" "$output")
    fi
    [[ $? -eq 0 && -f $output ]] && _HandleResult "Convert '$sourceImage' to '$output' success" && \
       return 0 || _HandleError "Failed converting '$sourceImage'" && return 1
  elif [[ $compress ]]; then
    if [[ ! $sourceImage =~ '^(jpg|jpeg|png|gif|bmp|tiff|tif|webp|jp2)$' ]]; then
      [[ ! -f $sourceImage ]] && _HandleError "sourceImage image not exists" && return 1
      local nameImage=${sourceImage%.*}
      local extImage=${sourceImage##*.}
      local watermark="compressed"
      local output="$nameImage-$watermark.$extImage"
      _HandleStart "Compressing $sourceImage"
      local processing=$(convert $sourceImage -compress Zip -quality 60 "$output")
      [[ $? -eq 0 ]] && _HandleResult "Success compressing to '$output'" && return 0 || \
        _HandleError "Failed compressing '$sourceImage'" && return 1
    elif [[ $sourceImage =~ '^(jpg|jpeg|png|gif|bmp|tiff|tif|webp|jp2)$' ]]; then
      find ./ -maxdepth 1 -type f -name "*.$sourceImage" | while IFS= read -r select; do
        [[ -z $select || ! $select ]] && _HandleError "Source image not exists" && return 1
        local nameImage=${select%.*}
        local extImage=${select##*.}
        local watermark="compressed"
        local output="$nameImage-$watermark.$extImage"
        echo -ne "${CYAN}Process:${RESET} Compressing ${GREEN}$select${RESET} to ${GREEN}$output${RESET} ~ "
        local processing=$(convert $select -compress Zip -quality 60 "$output")
        [[ $? -eq 0 && -f $output ]] && echo "${GREEN}OK${RESET}" || \
          echo "${RED}FAILED${RESET}" && return 1
      done
    fi
  fi
}

function document_tools(){
  [[ ! $(_found pandoc) ]] && _checkingPackage -i pandoc
  [[ ! $(_found gs) ]] && _checkingPackage -i ghostscript
  if [[ ! $(_found pdftk) ]]; then
    if [[ $_packageManager == "apk" ]]; then
      _HandleStart "Add compability to repository"
      local addingRepo=$(sudo sh -c 'echo -ne "\nhttps://dl-cdn.alpinelinux.org/alpine/v3.8/main\nhttps://dl-cdn.alpinelinux.org/alpine/v3.8/community" >> /etc/apk/repositories' &>/dev/null)
      _HandleStart "Updating repository"
      local process=$(update 2>/dev/null)
      _checkingPackage -i pdftk
    else
      _checkingPackage -i pdftk
    fi
  fi
  [[ ! $(_found pandoc) || ! $(_found gs) || ! $(_found pdftk) ]] && \
    _HandleError "Need some dependencies, run 'documment_tools' again!" && return 1
  local docExtension=("abw" "aw" "csv" "dbk" "djvu" "doc" "docm" "docx" \
    "dot" "dotm" "dotx" "html" "kwd" "odt" "oxps" "pdf" "rtf" \
    "sxw" "txt" "wps" "xls" "xlsx" "xps")
  function _document_tools_usage(){
    echo "Usage: document_tools [options] <path/file>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -c        Convert document mode"
    echo "    -e        Extension"
    echo "    -h        Show this message"
    echo "    -m        Merge PDF mode (all existed pdf)"
    echo "    -o        Target output file"
  }
  local __merge=false __convert=false
  PS3="$(_HandleCustom ${CYAN} "Select:" "")"
  while getopts ":m:f:o:q:h" opt; do
    case $opt in
      m ) local __merge=true && local __input="$OPTARG" ;;
      c ) local __convert=true && local __input="$OPTARG" ;;
      o ) local __output="$OPTARG" ;;
      e ) local __extension="$OPTARG" ;;
      h ) _document_tools_usage; return 0;;
      \?) _HandleWarn "Invalid option" >&2; return 1; break;;
      : ) _HandleError "Option '-$OPTARG' requires" >&2; return 1; break;;
    esac
  done
  if [[ $# -eq 0 ]]; then _document_tools_usage && return 1; fi
  if [[ "${docExtension[*]}" =~ "\\b($__input)\\b" ]]; then
    if $__merge && $__convert; then _HandleError "Only one option you can do!" && return 1; fi
    if [[ $__merge ]]; then
      local getAllFile=($(find ./ -maxdepth 1 -type f -name "*.${__input}" -exec basename {} \; | tr '\n' ' '))
      [[ ${#getAllFile[@]} == 0 ]] && echo "File does not exist" && return 1
      [[ ! $__output ]] && __output="$(date +"%Y-%m-%d_%H:%M-merged").pdf"
      [[ ${__output##*.} != "pdf" ]] && _HandleError "Only extension PDF can used merge documments" && return 1 && break
      echo -ne "${CYAN}Process:${RESET} Merger to ${GREEN}$__output${RESET} ~ "
      local process=$(pdftk "${getAllFile[@]}" cat output "$__output")
      [[ $? -eq 0 && -f $__output ]] && echo "${GREEN}OK${RESET}" && return 0 || \
        echo "${RED}FAILED${RESET}" && return 1
    elif [[ $__convert ]]; then
      find ./ -maxdepth 1 -name "${__input##*.}" -type f | while read -r select; do
        [[ ! $select ]] && _HandleError "File does not exits" && return 1 && break
        [[ ! $__output ]] && _HandleError "Need output option!" && return 1 && break
        [[ ! "${docExtension[*]}" =~ "\\b($__output)\\b" ]] && local _output="${__output##*.}" || local _output="$__output"
        echo -ne "${CYAN}Process:${RESET} Convert ${GREEN}$select${RESET} to ${GREEN}$_output${RESET} ~ "
        local process=$(pandoc "$select" -o "${select%.*}.${_output##*.}")
        [[ $? -eq 0 && -f $_output ]] && echo "${GREEN}OK${RESET}" && return 0 || \
          echo "${RED}FAILED${RESET}" && return 1
      done
    fi
  else
    if $__merge && $__convert; then _HandleError "Only one option you can do!" && return 1; fi
    [[ ! -f $__input ]] && _HandleError "No such file existed!" && return 1
    if [[ $__merge ]]; then
      _HandleWarn "Only can use multiple documents. Try using 'pdf'!"
      return 0
    elif [[ $__convert ]]; then
      [[ -z $__output ]] && _HandleError "Need output option!" && return 1 && break
      [[ ! "${docExtension[*]}" =~ "\\b($__output)\\b" ]] && local _output="${__output##*.}" || local _output="$__output"
      _HandleStart "Convert $__input to $_output"
      local process=$(pandoc "$__input" -o "${__input%.*}.$_output")
      [[ $? -eq 0 && -f $_output ]] && _HandleResult "Convert '$__input' to '$_output' success" && \
        return 0 || _HandleError "Failed converting '$__input'" && return 1
    fi
  fi
}

function media_tools(){
  [[ ! $(_found ffmpeg) ]] && _checkingPackage -i ffmpeg
  function _media_tools_usage(){
    echo "Usage  : media_tools [OPTION] <format>"
    echo ""
    echo "------------------------------------------------"
    echo "Options:"
    echo "    -h         Show this help message"
    echo "    -i         Input file"
    echo "    -f         Format extension file for output"
    echo "    -o         Output is optional, use for rename"
    echo "    -q         Set quality [default : medium]"
    echo "    -s         Resize for video [comming soon]"
    echo ""
  }
  local _all_video="3g2 3gp aaf asf av1 avchd avi cavs divx dv f4v \
    flv hevc m2ts m2v m4v mjpeg mkv mod mov mp4 mpeg mpeg-2 mpg mts \
    mxf ogv rm rmvb swf tod ts vob webm wmv wtv xvid"
  local _all_audio="8svx aac ac3 aiff amb amr ape au avr caf cdda cvs \
    cvsd cvu dss dts dvms fap flac fssd gsm gsrt hcom htk ima ircam m4a \
    m4r maud mp2 mp3 nist oga ogg opus paf prc pvf ra sd2 shn sln smp snd \
    sndr sndt sou sph spx tak tta txw vms voc vox vqf w64 wav wma wv wve xa"
  local input="" media="" output="" quality="medium" resize=""
  while getopts ":i:f:o:q:s:h" opt; do
    case $opt in
      i ) input="$OPTARG";;
      f ) format="$OPTARG";;
      o ) output="$OPTARG";;
      q ) quality="$OPTARG";;
      s ) resize="$OPTARG";;
      h ) _media_tools_usage;;
      \? ) _HandleError "Invalid option: -$OPTARG" >&2;;
      : ) _HandleWarn "Option -$OPTARG requires an argument." >&2;;
    esac
  done

  [[ -z $input || -z $format ]] && _HandleError "Missing input and format options." && return 1
  [[ -z $output ]] && output="${input%.*}.${format##*.}"
  local rv="" ext="${input%.*}" _output_ext="${output##*.}" _output_allow_ext="mp3 m4a opus flac"
  [[ $_all_video =~ (^|[[:space:]])$ext($|[[:space:]]) && $_output_allow_ext =~ (^|[[:space:]])$_output_ext($|[[:space:]]) ]] && rv="-vn"
  [[ -n "$rv" ]] && local ffmpeg_command="ffmpeg -i '$input' $rv" || \
    local ffmpeg_command="ffmpeg -i '$input'"

  case ${output##*.} in
    mp3 ) case $quality in
        very-low) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 9 '$output'" && break;;
        low) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 7 '$output'" && break;;
        medium) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 5 '$output'" && break;;
        high) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 2 '$output'" && break;;
        very-high) sh -c "$ffmpeg_command $rv -c:a libmp3lame -q:a 0 '$output'" && break;;
      esac;;
    m4a ) case $quality in
        very-low) sh -c "$ffmpeg_command $rv -c:a aac -b:a 64k '$output'" && break;;
        low) sh -c "$ffmpeg_command $rv -c:a aac -b:a 96k '$output'" && break;;
        medium) sh -c "$ffmpeg_command $rv -c:a aac -b:a 128k '$output'" && break;;
        high) sh -c "$ffmpeg_command $rv -c:a aac -b:a 192k '$output'" && break;;
        very-high) sh -c "$ffmpeg_command $rv -c:a aac -b:a 256k '$output'" && break;;
      esac;;
    opus ) case $quality in
        very-low) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 32k '$output'" && break;;
        low) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 64k '$output'" && break;;
        medium) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 96k '$output'" && break;;
        high) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 128k '$output'" && break;;
        very-high) sh -c "$ffmpeg_command $rv -c:a libopus -b:a 192k '$output'" && break;;
      esac;;
    flac ) case $quality in
        very-low) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 0 '$output'" && break;;
        low) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 4 '$output'" && break;;
        medium) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 8 '$output'" && break;;
        high) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 12 '$output'" && break;;
        very-high) sh -c "$ffmpeg_command $rv -c:a flac -compression_level 16 '$output'" && break;;
      esac;;
    mp4 | mkv | flv | avi) case $quality in
        very-low) sh -c "$ffmpeg_command -c:v libx264 -crf 32 -c:a aac -b:a 96k '$output'" && break;;
        low) sh -c "$ffmpeg_command -c:v libx264 -crf 28 -c:a aac -b:a 128k '$output'" && break;;
        medium) sh -c "$ffmpeg_command -c:v libx264 -crf 23 -c:a aac -b:a 192k '$output'" && break;;
        high) sh -c "$ffmpeg_command -c:v libx264 -crf 18 -c:a aac -b:a 256k '$output'" && break;;
        very-high) sh -c "$ffmpeg_command -c:v libx264 -crf 14 -c:a aac -b:a 320k '$output'" && break;;
      esac;;
    hevc) case $quality in
        very-low) sh -c "$ffmpeg_command -c:v libx265 -crf 35 -c:a aac -b:a 96k '${output##*.}.mp4'" && break;;
        low) sh -c "$ffmpeg_command -c:v libx265 -crf 28 -c:a aac -b:a 128k '${output##*.}.mp4'" && break;;
        medium) sh -c "$ffmpeg_command -c:v libx265 -crf 23 -c:a aac -b:a 192k '${output##*.}.mp4'" && break;;
        high) sh -c "$ffmpeg_command -c:v libx265 -crf 18 -c:a aac -b:a 256k '${output##*.}.mp4'" && break;;
        very-high) sh -c "$ffmpeg_command -c:v libx265 -crf 14 -c:a aac -b:a 320k '${output##*.}.mp4'" && break;;
      esac;;
    webm) case $quality in
        very-low) sh -c "$ffmpeg_command -c:v libvpx -crf 35 -b:v 100K -c:a libvorbis -b:a 64K '$output'" && break;;
        low) sh -c "$ffmpeg_command -c:v libvpx -crf 28 -b:v 500K -c:a libvorbis -b:a 128K '$output'" && break;;
        medium) sh -c "$ffmpeg_command -c:v libvpx -crf 23 -b:v 1M -c:a libvorbis -b:a 192K '$output'" && break;;
        high) sh -c "$ffmpeg_command -c:v libvpx -crf 18 -b:v 2M -c:a libvorbis -b:a 256K '$output'" && break;;
        very-high) sh -c "$ffmpeg_command -c:v libvpx -crf 14 -b:v 4M -c:a libvorbis -b:a 320K '$output'" && break;;
      esac;;
    *) _HandleError "Invalid audio output format: '$output'" && break
  esac
}

############################ END TOOLS ############################