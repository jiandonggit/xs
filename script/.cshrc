set autolist=ambiguous
set mail 
set rmstar
#set complete=enhance
#set correct=cmd
unalias *

setenv EDITOR vim
setenv BROWSER firefox
setenv PDF_READER evince

set prompt='%{^[[36m%}[%T %n@%m %c]\$%{^[[0m%} '
#set tperiod=1

### alias
#alias periodic date
#alias nlint "nLint"
alias ls        '\ls --color=auto'
alias ll        '\ls --color=auto -l'
alias l.        '\ls --color=auto -d .*'
alias ll.       '\ls --color=auto -l -d .*'
alias cd        'chdir -l \!*;ls'
alias c         cd ..
alias dc        cd
alias vi        vim
alias iv        vim
alias v         vim
#alias gvim      'gvim --remote-tab-silent'
#alias g        gvim
alias gvi       gvim
alias gv        gvim
alias grep      '\grep --color=auto'
alias rc        'vim ~/.cshrc; source ~/.cshrc'
alias h         'history \!*'
alias info      'pinfo'
alias vc        'vncconfig -nowin&'

