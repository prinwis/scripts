# returns for non-interactive shells
[[ $- != *i* ]] && return

# Easy extract
function q-extract
{
    if [ -f $1 ] ; then
        case $1 in
        *.tar.bz2)   tar -X ${HOME}/.local/etc/archive_exclude.txt -xvjf $1  ;;
        *.tar.gz)    tar -X ${HOME}/.local/etc/archive_exclude.txt -xvzf $1  ;;
        *.tar.xz)    tar -X ${HOME}/.local/etc/archive_exclude.txt -xvJf $1  ;;
        *.tar.7z)    7za x -xr@${HOME}/.local/etc/archive_exclude.txt -so $1 | tar -X ${HOME}/.local/etc/archive_exclude.txtxf -  ;;
        *.bz2)       7za x -xr@${HOME}/.local/etc/archive_exclude.txt -tbzip2 $1  ;;
        *.rar)       unrar x -x@${HOME}/.local/etc/archive_exclude.txt $1  ;;
        *.gz)        7za x -xr@${HOME}/.local/etc/archive_exclude.txt -tgzip $1  ;;
        *.tar)       tar -X ${HOME}/.local/etc/archive_exclude.txt -xvf $1   ;;
        *.tbz2)      tar -X ${HOME}/.local/etc/archive_exclude.txt -xvjf $1  ;;
        *.tgz)       tar -X ${HOME}/.local/etc/archive_exclude.txt -xvzf $1  ;;
        *.zip)       7za x -xr@${HOME}/.local/etc/archive_exclude.txt -tzip $1  ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7za x -xr@${HOME}/.local/etc/archive_exclude.txt $1  ;;
        *)           echo "don't know how to extract '$1'..."  ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# easy compress - archive wrapper
function q-compress
{
    if [ -n "$1" ] ; then
        FILE=$1
        case $FILE in
        *.tar) shift && tar -X ${HOME}/.local/etc/archive_exclude.txt -cf $FILE $*       ;;
        *.tar.bz2) shift && tar -X ${HOME}/.local/etc/archive_exclude.txt -cjf $FILE $*  ;;
        *.tar.xz) shift && tar -X ${HOME}/.local/etc/archive_exclude.txt -cJf $FILE $*   ;;
        *.tar.gz) shift && tar -X ${HOME}/.local/etc/archive_exclude.txt -czf $FILE $*   ;;
        *.tar.7z) shift && tar -X ${HOME}/.local/etc/archive_exclude.txt -cf - $* | 7za a -xr@${HOME}/.local/etc/archive_exclude.txt -t7z -si $FILE  ;;
        *.tgz) shift && tar -X ${HOME}/.local/etc/archive_exclude.txt -czf $FILE $*      ;;
        *.zip) shift && 7za a -xr@${HOME}/.local/etc/archive_exclude.txt -tzip $FILE $*  ;;
        *.7z) shift && 7za a -xr@${HOME}/.local/etc/archive_exclude.txt -t7z $FILE $*    ;;
        *) echo "don't know how to compress '$1'..." ;;
        esac
    else
        echo "usage: q-compress <foo.compress_type> ./foo"
    fi
}



function m() {
    MARKPATH="${MARKPATH:-$HOME/.local/share/marks}"
    [ -d "$MARKPATH" ] || mkdir -p -m 700 "$MARKPATH" 2> /dev/null
    case "$1" in
        +*)            # m +foo  - add new bookmark for $PWD
            ln -snf "$(pwd)" "$MARKPATH/${1:1}" 
            ;;
        -*)            # m -foo  - delete a bookmark named "foo"
            rm -i "$MARKPATH/${1:1}" 
            ;;
        /*)            # m /bar  - search bookmarks matching "bar"
            find "$MARKPATH" -type l -name "*${1:1}*" | \
                awk -F "/" '{print $NF}' | MARKPATH="$MARKPATH" xargs -I'{}'\
                sh -c 'echo "{} ->" $(readlink "$MARKPATH/{}")'
            ;;
        "")            # m       - list all bookmarks
            command ls -1 "$MARKPATH/" | MARKPATH="$MARKPATH" xargs -I'{}' \
                sh -c 'echo "{} ->" $(readlink "$MARKPATH/{}")'
            ;;
        *)             # m foo   - cd to the bookmark directory
            local dest="$(readlink "$MARKPATH/$1" 2> /dev/null)"
            [ -d "$dest" ] && cd "$dest" || echo "No such mark: $1"
            ;;
    esac
}

if [ -n "$BASH_VERSION" ]; then
    function _cdmark_complete() {
        local MARKPATH="${MARKPATH:-$HOME/.local/share/marks}"
        local curword="${COMP_WORDS[COMP_CWORD]}"
        if [[ "$curword" == "-"* ]]; then
            COMPREPLY=($(find "$MARKPATH" -type l -name "${curword:1}*" \
                2> /dev/null | awk -F "/" '{print "-"$NF}'))
        else
            COMPREPLY=($(find "$MARKPATH" -type l -name "${curword}*" \
                2> /dev/null | awk -F "/" '{print $NF}'))
        fi
    }
    complete -F _cdmark_complete m
elif [ -n "$ZSH_VERSION" ]; then
    function _cdmark_cwmplete() {
        local MARKPATH="${MARKPATH:-$HOME/.local/share/marks}"
        if [[ "${1}${2}" == "-"* ]]; then
            reply=($(command ls -1 "$MARKPATH" 2> /dev/null | \
                awk '{print "-"$0}'))
        else
            reply=($(command ls -1 "$MARKPATH" 2> /dev/null))
        fi
    }
    compctl -K _cdmark_complete m
fi



# 数字进制转换
0x() {
    echo $((16#$1))
}

0o() {
    echo $((8#$1))
}

0b() {
    echo $((2#$1))
}

p16() {
    echo $(([#16] $1))
}

p8() {
    echo $(([#8] $1))
}

p2() {
    echo $(([#2] $1))
}
