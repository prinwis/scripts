export PATH="/usr/local/opt/flex/bin:/usr/local/opt/coreutils/libexec/gnubin/:/usr/local/share/dotnet:/Users/prinwis/texlive/2018/bin/x86_64-darwin/:/usr/local/opt/ruby/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/prinwis/bin/FDK/Tools/osx:/Users/prinwis/Library/Python/3.7/bin"
#export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
# export LDFLAGS="/usr/local/opt/ruby/lib:/usr/local/opt/flex/lib"
# export CPPFLAGS="-I /usr/local/opt/ruby/include -I/usr/local/opt/flex/include"
# export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"


setopt prompt_subst
source ~/Scripts/fish_prompt.sh
# prompt
# PROMPT="%{%F{045}%}%~%{%F{cyan}%}> %{%F{white}%}"
# PROMPT="%{%F{045}%}$(_fish_collapsed_pwd)%{%F{cyan}%}> %{%F{white}%}"
# RPROMPT="%{%F{green}%}%n@%M"

# bindkey "\e[1~" beginning-of-line
# bindkey "\e[4~" end-of-line
#alias
alias cls='clear && echo -en "\e[3J"'
alias ls='ls --color'
alias ll='ls -lh --color'
alias la='ls -A --color'
alias lla='ls -lAh --color'
alias mvi='mv -i'

setopt MENU_COMPLETE
precmd() {
    [[ $TERM == screen* ]] && print -Pn "\ek%30<..<%~%<<\e\\"
    echo -ne "\e]1;${PWD##*/}\a"

}

case $TERM {
    (screen*)
    preexec() {
        # \ek 起始
        # %30>..内容%<<  如果超过 30 个字符就从右截断
        # ${1/[\\\%]*/@@@} 截断 \ 和 % 之后的内容，避免出乱码输出
        # \e\\ 终止
        print -Pn "\ek%30>..>${1/[\\\%]*/@@@}%<<\e\\"
    }
    ;;

    (xterm*)
    preexec() {
        # \e]0;内容\a
        print -Pn "\e]0;%~$ ${1/[\\\%]*/@@@}\a"
    }
    ;;
}


#{{{ 关于历史纪录的配置
# 历史纪录条目数量
export HISTSIZE=10000
# 注销后保存的历史纪录条目数量
export SAVEHIST=10000
# 历史纪录文件
export HISTFILE=~/.zhistory
# 修改 esc 超时时间为 0.01s
export KEYTIMEOUT=1
# 多个 zsh 间分享历史纪录
#setopt SHARE_HISTORY
# 如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS
# 为历史纪录中的命令添加时间戳
#setopt EXTENDED_HISTORY
# 启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD
# 相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS
# 在命令前添加空格，不将此命令添加到纪录文件中
setopt HIST_IGNORE_SPACE
# 加强版通配符
setopt EXTENDED_GLOB
# 在后台运行命令时不调整优先级
setopt NO_BG_NICE
# 禁用终端响铃
unsetopt BEEP
#}}}


#{{{ 自动补全
# 扩展路径
# /u/l/b => /usr/local/bin
setopt complete_in_word

#以下字符视为单词的一部分
WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

setopt AUTO_LIST
setopt AUTO_MENU
# 开启此选项，补全时会直接选中菜单项
# setopt MENU_COMPLETE
#
# fpath+=(~/.bin/comp)
autoload -U compinit
compinit

_force_rehash() {
    ((CURRENT == 1)) && rehash
    return 1    # Because we didn't really complete anything
}
zstyle ':completion:::::' completer _force_rehash _complete _approximate

# 自动补全选项
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select
zstyle ':completion:*:*:default' force-list always
zstyle ':completion:*' select-prompt '%SSelect:  lines: %L  matches: %M  [%p]'
zstyle ':completion:*:match:*' original only
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate

# 路径补全
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'
zstyle ':completion::complete:*' '\\'

# 彩色补全菜单
export ZLSCOLORS=$LS_COLORS
zmodload zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 修正大小写
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# 错误校正
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# 补全类型提示分组
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[01;35m -- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
zstyle ':completion:*:corrections' format $'\e[01;32m -- %d (errors: %e) --\e[0m'

# kill 补全
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'

# cd ~ 补全顺序
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

# 空行(光标在行首)补全 "cd "
user-complete() {
    case $BUFFER {
        "" )
            # 空行填入 "cd "
            BUFFER="cd "
            zle end-of-line
            zle expand-or-complete
            ;;

        " " )
            BUFFER="!?"
            zle end-of-line
            zle expand-or-complete
            ;;

        * )
            zle expand-or-complete
            ;;
    }
}

zle -N user-complete
bindkey "\t" user-complete
##}}}

#{{{ 杂项
# 进入相应的路径时只要 cd ~xxx
# hash -d mine='/mnt/c/mine'

# 加载函数
autoload -U zmv

# key
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

# man 颜色
export LESS_TERMCAP_mb=$'\E[01;31m'
# 标题和命令主体
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
# 命令参数
export LESS_TERMCAP_us=$'\E[04;36;4m'


zsh_hi='/usr/local/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
source ${zsh_hi}

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# opam configuration

unsetopt correct_all
unsetopt correct
DISABLE_CORRECTION="true" 

# eval "$(lua ~/Repos/z.lua/z.lua  --init zsh once enhanced)"
