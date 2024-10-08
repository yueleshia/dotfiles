#run: nickel export % --field text --format raw

{ executable = true, text = m%"
#let xdg_config = "$HOME/.config"
source "$HOME/.profile"
source "$HOME/.config/aliasrc"
#export timer = "$(date +%s)"
export GPG_TTY="$( tty )"

# Do not `lx` if directory change failed
#fn c target; cd "$(namedpath "$target")" && ls .;  end

# What a hack job, still no idea how to do variable arguments for functions
# @args is for the parameters of the current shell
fn cd_of a b c d e
  let temp = "$($a $b $c $d $e)"
  cd "$temp" && ls --color=auto --group-directories-first -hA
end

alias rrc = "source $HOME/.config/ion/initrc; source $HOME/.profile"
#export SECONDS="$(date +%s)"


fn PROMPT
  #let now           = "$(date +%s)"
  let exitcode      = "$?" # this does not work
  #let timer         = "$(expr "$now" - "$SECONDS")"
  let timer         = '0'
  let backgroundpid = '1'

  "$HOME/.config/prompt.sh" "$exitcode" "$timer" "$backgroundpid"
  #export SECONDS="$now"
end

"% }
