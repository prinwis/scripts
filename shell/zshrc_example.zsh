# --- ~/.zshenv
unsetopt GLOBAL_RCS
export ZDOTDIR="$HOME/.config/zsh"
source "$ZDOTDIR/.zshenv"
# end

# -- $ZDOTDIR/.zshenv

# 设置XDG_SPEC变量
export ZDOTDIR="$HOME/.config/zsh"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export IPYTHONDIR="$XDG_CONFIG_HOME/jupyter"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'

# PATH相关
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[[ -d $HOME/.local/bin ]] && PATH="$HOME/.local/bin:$PATH"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
[[ -d $CARGO_HOME ]] && PATH="$CARGO_HOME/bin:$PATH"
export PATH

if [ -x "$(command -v nvim)" ]; then
    export EDITOR="nvim"
elif [ -x "$(command -v vim)" ]; then
    export EDITOR="vim"
fi

export PAGER="less"

# 禁止homebrew自动更新
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

# Locale相关
export LANG=en_US.UTF-8
export LANGUAGE=en_US
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


[ -f "$HOME/.local/etc/config.sh" ] && source "$HOME/.local/etc/config.sh"
[ -f "$HOME/.local/etc/config.zsh" ] && source "$HOME/.local/etc/config.zsh"

# zshrc

[[ $- != *i* ]] && return

# 检测终端是否支持24bit颜色和内置poweline字符
HAS_TRUE_COLOR=0
HAS_BUILTIN_POWERLINE=0

if [[ $(uname -a) == *Darwin* ]] && [[ $TERM_PROGRAM == "iTerm.app" ]] ; then
    HAS_TRUE_COLOR=1
    HAS_BUILTIN_POWERLINE=1
fi

if [[ -z $SSH_CONNECTION ]] ; then
    if [[ "$(uname -a)" == *Microsoft* ]] ; then
        HAS_TRUE_COLOR=1
    fi
elif [[ $LC_TERMINAL == 'iTerm2' ]] ; then
    HAS_TRUE_COLOR=1
    HAS_BUILTIN_POWERLINE=1
fi

if [[ $TERM_PROGRAM == 'vscode' ]] ; then
    HAS_TRUE_COLOR=1
    HAS_BUILTIN_POWERLINE=0
fi
setopt PROMPT_SUBST


export TERM="xterm-256color"
export HAS_TRUE_COLOR
export HAS_BUILTIN_POWERLINE

if [[ $HAS_TRUE_COLOR -eq 1 ]] ; then
    export COLORTERM='truecolor'
else
    zmodload zsh/nearcolor
fi


function _venv_name {
    [[ -n $VIRTUAL_ENV ]] && echo "[$(basename $VIRTUAL_ENV)]"
}

function _fish_collapsed_pwd() {
    local pwd="$1"
    local home="$HOME"
    local size=${#home}
    [[ $# == 0 ]] && pwd="$PWD"
    [[ -z "$pwd" ]] && return
    if [[ "$pwd" == "/" ]]; then
        echo "/"
        return
    elif [[ "$pwd" == "$home" ]]; then
        echo "~"
        return
    fi
    [[ "$pwd" == "$home/"* ]] && pwd="~${pwd:$size}"
    if [[ -n "$BASH_VERSION" ]]; then
        local IFS="/"
        local elements=($pwd)
        local length=${#elements[@]}
        for ((i=0;i<length-1;i++)); do
            local elem=${elements[$i]}
            if [[ ${#elem} -gt 1 ]]; then
                elements[$i]=${elem:0:1}
            fi
        done
    else
        local elements=("${(s:/:)pwd}")
        local length=${#elements}
        for i in {1..$((length-1))}; do
            local elem=${elements[$i]}
            if [[ ${#elem} > 1 ]]; then
                elements[$i]=${elem[1]}
            fi
        done
    fi
    local IFS="/"
    echo "${elements[*]}"
}

export VIRTUAL_ENV_DISABLE_PROMPT=1

if [[ $HAS_TRUE_COLOR -eq 1 ]] && [[ $HAS_BUILTIN_POWERLINE -eq 1 ]] ; then
    export PROMPT=$'%K{#0090e0}%F{#e8e8e8}$(_fish_collapsed_pwd)%k%f%F{#0090e0}\uE0B0%k%f '
    export RPROMPT=$'%F{#0090e0}\uE0B2%(?..%K{#0060c0}%F{#0090e0}%F{#e8e8e8}[%?]%F{#0090e0}\uE0B2%k%f)%F{#e8e8e8}%K{#0090e0}%n@%M%k%f'
elif [[ $HAS_TRUE_COLOR -eq 1 ]] ; then
    export PROMPT=$'%F{#0090e0}$(_venv_name)$(_fish_collapsed_pwd)>%f '
    export RPROMPT=$'%F{#0090e0}%n@%M%f'
else
    export PROMPT=$'%F{32}$(_venv_name)$(_fish_collapsed_pwd)>%f '
    export RPROMPT="%F{32}%n@%M%f"
fi

# 标题栏设置为User@Host
precmd() {
    echo -ne "\033]0;${USERNAME}@${HOST}\007"
}



export _ZL_DATA="$XDG_DATA_HOME/zlua_data"
export _ZL_MATCH_MODE=1
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone "https://github.com/zdharma-continuum/zinit.git" "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"
# If you place the source below compinit, then add those two lines after the source
# autoload -Uz _zinit
# (( ${+_comps} )) && _comps[zinit]=_zinit

zinit wait lucid atload"zicompinit; zicdreplay" blockf for \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions \
    skywind3000/z.lua

# zinit ice depth=1; zinit light romkatv/powerlevel10k

# 禁用终端响铃
unsetopt BEEP
# 使用下面的选项时，按tab会直接选中菜单
# setopt MENU_COMPLETE

setopt AUTO_LIST
setopt AUTO_MENU
# 扩展路径
# /v/c/p/p => /var/cache/pacman/pkg
setopt complete_in_word
#以下字符视为单词的一部分
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'
# ----- 历史记录 ---------
# 历史纪录条目数量
export HISTSIZE=100000
# 注销后保存的历史纪录条目数量
export SAVEHIST=100000
# 历史纪录文件
export HISTFILE="$ZDOTDIR/.zsh_history"
# 多个 zsh 间分享历史纪录
setopt SHARE_HISTORY
# 如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS
# 为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY
# 启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD
# 相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS
# 在命令前添加空格，不将此命令添加到纪录文件中
setopt HIST_IGNORE_SPACE
# 加强版通配符
setopt EXTENDED_GLOB
# 在后台运行命令时不调整优先级
# setopt NO_BG_NICE

alias du='du -h'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF'
alias ls='ls --color=auto'
alias la='ls -Ah'
alias ll='ls -AlhF'
alias s='ssh'
alias socks5='http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 all_proxy=http://127.0.0.1:7890 '
alias tree='tree -N'

# ------- 补全 --------------
# syntax color definition
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)


export ZSH_AUTOSUGGEST_USE_ASYNC=1


autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

[ -f $HOME/.local/etc/lscolors ] && source $HOME/.local/etc/lscolors
# 令补全不区分大小写
zstyle ':completion:*:*:foo:*' tag-order '*' '*:-case'
zstyle ':completion:*-case' matcher 'm:{a-z}={A-Z}'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
         'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*:*sh:*:' tag-order files
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# 令文件补全显示点号开头的隐藏文件，但不显示.和..
setopt globdots
_comp_options+=(globdots)

# zstyle ':completion:*:complete:-command-:*:*' ignored-patterns '*.exe|*.dll'

# Highlight the current autocomplete option
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better SSH/Rsync/SCP Autocomplete
# zstyle ':completion:*:(scp|rsync):*' tag-order ' hosts:-ipaddr:ip\ address hosts:-host:host files'
# zstyle ':completion:*:(scp|rsync):*' tag-order 'files'
# zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns \
#     '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
# zstyle ':completion:*:(scp|rsync):*' ignored-patterns hosts:-ipaddr:ip address hosts:-host:host
# zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns \
#     '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' \
#     '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*' '_[a-z]*'
# 路径补全
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'
zstyle ':completion::complete:*' '\\'

# 错误校正
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' menu select
# 补全类型提示分组
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[01;35m -- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
zstyle ':completion:*:corrections' format $'\e[01;32m -- %d (errors: %e) --\e[0m'
# zstyle ":completion:*:default" list-colors ${(s.:.)LS_COLORS} "ma=48;2;53;53;53"
# 彩色补全菜单
export ZLSCOLORS=$LS_COLORS


# user-complete() {
#     case $BUFFER {
#         "" )
#             # 空行填入 "cd "
#             BUFFER="cd "
#             zle end-of-line
#             zle expand-or-complete
#             ;;

#         " " )
#             BUFFER="!?"
#             zle end-of-line
#             zle expand-or-complete
#             ;;

#         * )
#             zle expand-or-complete
#             ;;
#     }
# }

# zle -N user-complete
# bindkey "\t" user-complete
# 修改 esc 超时时间为 0.01s
export KEYTIMEOUT=1

# bindkey "^[[1~" beginning-of-line
# bindkey "^[[4~" end-of-line
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey -s "\eo" "cd ..\n"
bindkey '\e[1;3D' backward-word       # ALT+左键：向后跳一个单词
bindkey '\e[1;3C' forward-word        # ALT+右键：前跳一个单词
bindkey '\e[1;3A' beginning-of-line   # ALT+上键：跳到行首
bindkey '\e[1;3B' end-of-line         # ALT+下键：调到行尾

[ -f "$HOME/.local/etc/func.sh" ] && source "$HOME/.local/etc/func.sh"


# config.sh

#PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
#PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
#PATH="$HOME/local/texlive2021/bin/universal-darwin:$PATH"
#PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
#PATH="$HOME/.cargo/bin:$PATH"
#PATH="$HOME/.local/bin:$PATH"
#export PATH

#export MANPATH="$HOME/local/texlive2021/texmf-dist/doc/man:$MANPATH"
#export INFOPATH="$HOME/local/texlive2021/texmf-dist/doc/info:$INFOPATH"

#export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
#export CMAKE_PREFIX_PATH="/usr/local/opt:${CMAKE_PREFIX_PATH}"
#export C_INCLUDE_PATH="${SDKROOT}/usr/include:${C_INCLUDE_PATH}"
#export CPLUS_INCLUDE_PATH="${SDKROOT}/usr/include/c++/v1:${SDKROOT}/usr/include:/usr/local/include:${CPLUS_INCLUDE_PATH}"
#export LIBRARY_PATH="/usr/local/lib:${LIBRARY_PATH}"

# alias subm='open -a Sublime\ Merge '
alias s='ssh'
alias ls='ls --color -I "\$RECYCLE.BIN" -I "System Volume Information"'
alias ll='ls -lAh -I "\$RECYCLE.BIN" -I "System Volume Information"'
alias la='ls -A --color -I "\$RECYCLE.BIN" -I "System Volume Information"'
#alias ipython='printf "\x1b]0;IPython:${USER}@${HOST}\x07"; ipython'
#alias ipython3='printf "\x1b]0;IPython3:${USER}@${HOST}\x07"; ipython3'
#alias tree='tree -N'
#alias uedit='open -a UltraEdit'
#alias pdf-unstamper="java -jar ${HOME}./local/lib/pdf-unstamper.jar"
alias socks5="http_proxy=http://127.0.0.1:1080 https_proxy=http://127.0.0.1:1080 all_proxy=http://127.0.0.1:1080 "

# func.sh
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

[ -f $HOME/.local/etc/m.sh ] && source "$HOME/.local/etc/m.sh"

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

# ls colors
LS_COLORS='no=00:fi=00:rs=0:di=00;36:ln=01;36:mh=00:pi=38;05;142;48;05;235:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=00;36:st=37;44:ex=01;32:*.tar=00;31:*.tgz=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.tlz=00;31:*.txz=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.dz=00;31:*.gz=00;31:*.lz=00;31:*.xz=00;31:*.bz2=00;31:*.bz=00;31:*.tbz=00;31:*.tbz2=00;31:*.tz=00;31:*.deb=00;31:*.rpm=00;31:*.jar=00;31:*.dll=01;35:*.rar=00;31:*.ace=00;31:*.zoo=00;31:*.cpio=00;31:*.7z=00;31:*.rz=00;31:*.apk=00;31:*.jpg=00;38;05;33:*.JPG=00;38;05;33:*.jpeg=00;38;05;33:*.gif=00;38;05;33:*.bmp=00;38;05;33:*.pbm=00;38;05;33:*.pgm=00;38;05;33:*.ppm=00;38;05;33:*.tga=00;38;05;33:*.xbm=00;38;05;33:*.xpm=00;38;05;33:*.tif=00;38;05;33:*.tiff=00;38;05;33:*.png=00;38;05;33:*.svg=00;38;05;33:*.svgz=00;38;05;33:*.mng=00;38;05;33:*.pcx=00;38;05;33:*.psd=00;38;05;33:*.aac=00;38;05;132:*.m4a=00;38;05;132:*.au=00;38;05;132:*.flac=00;38;05;132:*.ape=00;38;05;132:*.mid=00;38;05;132:*.midi=00;38;05;132:*.mka=00;38;05;132:*.mp3=00;38;05;132:*.mpc=00;38;05;132:*.ogg=00;38;05;132:*.ra=00;38;05;132:*.wav=00;38;05;132:*.axa=00;38;05;132:*.oga=00;38;05;132:*.spx=00;38;05;132:*.xspf=00;38;05;132:*.mov=00;35:*.mpg=00;35:*.mpeg=00;35:*.m2v=00;35:*.mkv=00;35:*.ogm=00;35:*.mp4=00;35:*.m4v=00;35:*.mp4v=00;35:*.vob=00;35:*.qt=00;35:*.nuv=00;35:*.wmv=00;35:*.asf=00;35:*.rm=00;35:*.rmvb=00;35:*.flc=00;35:*.avi=00;35:*.fli=00;35:*.flv=00;35:*.gl=00;35:*.dl=00;35:*.xcf=00;35:*.xwd=00;35:*.yuv=00;35:*.cgm=00;35:*.emf=00;35:*.f4v=00;35:*.axv=00;35:*.anx=00;35:*.ogv=00;35:*.ogx=00;35:*.3gp=00;35:*.mts=00;35:*.ts=00;35:*.pdf=00;32:*.epub=00;32:*.kfx=00;32:*.mobi=00;32:*.azw=00;32:*.azw3=00;32:*.ps=00;32:*.txt=00;32:*.patch=00;32:*.diff=00;32:*.log=00;32:*.tex=00;32:*.doc=00;32:*.docx=00;32:*.htm=00;32:*.html=00;32:*.md=00;32:*.mht=00;32:*.chm=00;32:*.xls=00;32:*.xlsx=00;32:*.ppt=00;32:*.pptx=00;32:*.djvu=00;32:*.c=00;33:*.cpp=00;33:*.js=00;33:*.java=00;33:*.sh=00;33:*.py=00;33:*.h=00;33:*.php=00;33:*.pl=00;33:*.tcl=00;33:*.rb=00;33:*.xml=00;33:*.tcl=00;33:*.zsh=00;33:*.C=00;33:*.lc=00;33:*.db=00;38;05;100:*.sqlite=00;38;05;100:*.iso=00;38;05;100:*.img=00;38;05;100:*.sfs=00;38;05;100:*Makefile=01;38;05;148:*CMakeLists.txt=01;38;05;148:*readme=01;38;05;148:*readme.txt=01;38;05;148:*README=01;38;05;148:*README.txt=01;38;05;148:*INSTALL=01;38;05;148:*FAQ=01;38;05;148:*TODO=01;38;05;100:*todo=01;38;05;100:';
export LS_COLORS