set -o emacs
set -o notify
alias essh='exec ssh'
# alias ssh='TERM=Eterm-color ssh'
shopt -s nocaseglob
shopt -s histappend
shopt -s cdspell
shopt -s expand_aliases
bind 'set match-hidden-files off'
source /usr/doc/git-1.6.4/contrib/completion/git-completion.bash
source /etc/profile.d/coreutils-dircolors.sh

export HISTSIZE=50000
export HISTCONTROL="ignoredups"
export HISTIGNORE="[   ]*"
export VISUAL=vim
export INPUTRC=/etc/inputrc
export PS1='\n[$USER@\e[0;32m$(echo $HOSTNAME | cut -d. -f1)\e[0m:$PWD]\n$ '
export DCO="grep pass ~/.neoconfig | head -1 | cut -d= -f2 | tr -d \" \""
export IDC="grep -A2 idc ~/.neoconfig | grep pass | cut -d= -f2 | tr -d \" \""
# export CVSROOT=/home/bharris/src/cvs/root
# export CVS_RSH="/usr/bin/ssh"
# export CVSROOT="bharris@sr:/usr/home/cvs/root"

# Notes
# =====
# _OPTS is used in case I want to login to the console by issuing a "-0" on
# the command line.  The others just get passed to the _rdesktop function.
# The _rdesktop function takes care of standard error output, as well as
# placing the process into the background.  However, it cannot locally disown
# the process correctly, which is why the disown takes place in each main
# function.  $DCO is not my password, it is a command which prints my password
# to the standard output by reading a .neoconfig file.  The format is below.
#
# [dco]
#     user = bharris
#     pass = aligator5
# [idc]
#     user = sqltest
#     pass = aligator5
bryanxp ()
{
    _OPTS=$1
    USER="bharris" \
    PASS=`/usr/bin/echo $DCO | sh` \
    DOMAIN="CORP" \
    OPTS="-x b -P -K -a16 -D -g1280x986" \
    SHARE="-r disk:share=/home/bharris/share/corp" \
    COMP="bryanxp" \
        _rdesktop
    _disown
}

rd ()
{
    _OPTS=$2
    USER="sqltest" \
    PASS=`xsel -b` \
    OPTS="-P -K -a16 -D -g1280x986" \
    SHARE="-r disk:share=/home/bharris/share/share" \
    COMP="$1" \
        _rdesktop_nodomain
    _disown
}

rddco () 
{ 
    _OPTS=$1
    USER="bharris" \
    PASS=`/usr/bin/echo $DCO | sh` \
    DOMAIN="DCO" \
    OPTS="-P -K -a16 -D -g1280x986" \
    SHARE="-r disk:share=/home/bharris/share/dco" \
    COMP=`xsel -b` \
        _rdesktop
    _disown
}

rdisn ()
{
    _OPTS=$1
    USER="sqltest" \
    PASS=`/usr/bin/echo $IDC | sh` \
    DOMAIN="ISN-PUBLIC" \
    OPTS="-0 -P -K -a16 -D -g1280x986" \
    SHARE="-r disk:share=/home/bharris/share/isn" \
    COMP=`xsel -b` \
        _rdesktop
    _disown
}

_rdesktop ()
{
    rdesktop $_OPTS -d$DOMAIN -u$USER -p$PASS $OPTS $SHARE $COMP &
} 2>/dev/null


_rdesktop_nodomain ()
{
    rdesktop $_OPTS -u$USER -p$PASS $OPTS $SHARE $COMP &
} 2>/dev/null


_disown ()
{
    disown %$(jobs | awk '$3~/skto/ {print $1}' | tr -d '[]+-')
}
