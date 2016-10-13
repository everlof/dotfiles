#!/bin/bash

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
    . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

alias python=python3.5
alias pip=python3.5

alias grep='grep --color=auto '

alias ll="ls -lhA"
alias l="ls -l"

__git_complete_remote_or_refspec_prpush ()
{
  local cur_="$cur" cmd="push"
  local i c=1 remote="" pfx="" lhs=1 no_complete_refspec=0
  if [ "$cmd" = "remote" ]; then
    ((c++))
  fi
  while [ $c -lt $cword ]; do
    i="${words[c]}"
    case "$i" in
    --mirror) [ "$cmd" = "push" ] && no_complete_refspec=1 ;;
    --all)
      case "$cmd" in
      push) no_complete_refspec=1 ;;
      fetch)
        return
        ;;
      *) ;;
      esac
      ;;
    -*) ;;
    *) remote="$i"; break ;;
    esac
    ((c++))
  done
  if [ -z "$remote" ]; then
    __gitcomp_nl "$(__git_remotes)"
    return
  fi
  if [ $no_complete_refspec = 1 ]; then
    return
  fi
  [ "$remote" = "." ] && remote=
  case "$cur_" in
  *:*)
    case "$COMP_WORDBREAKS" in
    *:*) : great ;;
    *)   pfx="${cur_%%:*}:" ;;
    esac
    cur_="${cur_#*:}"
    lhs=0
    ;;
  +*)
    pfx="+"
    cur_="${cur_#+}"
    ;;
  esac
  case "$cmd" in
  fetch)
    if [ $lhs = 1 ]; then
      __gitcomp_nl "$(__git_refs2 "$remote")" "$pfx" "$cur_"
    else
      __gitcomp_nl "$(__git_refs)" "$pfx" "$cur_"
    fi
    ;;
  pull|remote)
    if [ $lhs = 1 ]; then
      __gitcomp_nl "$(__git_refs "$remote")" "$pfx" "$cur_"
    else
      __gitcomp_nl "$(__git_refs)" "$pfx" "$cur_"
    fi
    ;;
  push|prpush|pr)
    if [ $lhs = 1 ]; then
      __gitcomp_nl "$(__git_refs)" "$pfx" "$cur_"
    else
      __gitcomp_nl "$(__git_refs "$remote")" "$pfx" "$cur_"
    fi
    ;;
  esac
}

_git_prpush ()
{
  __git_complete_remote_or_refspec_prpush
}

alias g=git
__git_complete g _git
__git_complete prpush _git_prpush
__git_complete pr _git_prpush

pjson () {
        ~/bin/pjson.py | less -X
}

export PATH="$PATH:$HOME/bin"

# brew install coreutils


prpush () {
  tmp=$(mktemp)
  git push $@ 2>&1 | tee "$tmp"
  to_open=$(grep https $tmp | awk '{ print $2 }' )
  rm "$tmp"
  open "$to_open"
}

pr () {
  remote=$1
  branch=$2

  if [ -z "$remote" ]
  then
    echo "usage: pr remote [branch]"
    return 1
  fi

  if [ -z "$branch" ]
  then
    branch=$(git rev-parse --abbrev-ref HEAD)
  fi

  # from the remote url we get the repo name, which is used in the url for BitBucker
  bb_reponame=$(git remote -v | grep '(push)' | grep $remote | cut -f2 | cut -d" " -f 1 | cut -d: -f 2 | cut -d. -f1)

  open "https://bitbucket.org/$bb_reponame/pull-requests/new?source=$branch"
}

parse_git_branch() {
    dirt_info=$(git status --short 2>/dev/null)
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

    if [ ${#dirt_info} -ne 0 ]
    then
      branch="${branch}~"
    fi

    if [ ${#branch} -gt 0 ]
    then
      echo "($branch)"
    fi
}

thumb() {
  if [ "$1" -eq 0 ]
  then
    echo -en "\xf0\x9f\x91\x8d" # Thumbs up!
  else
    echo -en "\xf0\x9f\x91\x8e" # Thumbs down!
  fi
}

export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH

function timer_start {
  timer=${timer:-$SECONDS}
}

function timer_stop {
  timer_show=$(($SECONDS - $timer))
  unset timer
}

trap 'timer_start' DEBUG

export PS1="$(thumb 0) \u@knowit \W\[\033[35m\]\$(parse_git_branch)\[\033[00m\] $ "

# Func to gen PS1 after CMDs
PROMPT_COMMAND=__prompt_command

__prompt_command() {
    local EXIT="$?"
    timer_stop
    PS1="$(thumb $EXIT)  \033[97m[last: ${timer_show}s]\033[00m \033[91m\D{%T}\033[00m \033[94m\w\033[00m \[\033[92m\]\$(parse_git_branch)\[\033[00m\]\n$ "
}

tpfix () {
  sed -i '' "s/$(echo -en '\\\u0403')/$(echo -en '\xc3\x85')/g" $1
  sed -i '' "s/$(echo -en '\\\u0402')/$(echo -en '\xc3\x84')/g" $1
  sed -i '' "s/$(echo -en '\\\u2026')/$(echo -en '\xc3\x96')/g" $1
}

heelp() {
  echo "Print the booted device's copyboard"
  echo "- xcrun simctl pbpaste booted"
}

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER)
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

urlparse() {
  eval $(url.py "$1" "$2")
}

escapeurl() {
  urlparse "$1"
  ENCODED_PATH=$(rawurlencode_tp "$_PATH")
  echo "${_SCHEME}://${_NETLOC}${ENCODED_PATH}"
}

if [ -f ~/.bash_profile_local ] ; then
  echo "Sourcing ~/.bash_profile_local"
  . ~/.bash_profile_local
fi
