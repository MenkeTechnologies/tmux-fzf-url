#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 12:12
#===============================================================================
exec 2>> "${ZPWR_LOGFILE:-${TMPDIR:-/tmp}/tmux-$(id -u)-fzf-url.log}" 1>&2

get_fzf_options() {

    local fzf_options="$(tmux show -gqv '@fzf-url-fzf-options')"
    local pre='x=$(echo {} | awk "{print \$2}"); curl -fsSL $x'
    local fzf_default_options="-d 35% -m -0 --no-border --preview '$pre'"
    echo "${fzf_options:-$fzf_default_options}"
}


limit="${1:-screen}"

if [[ $limit == 'screen' ]]; then
    content="$(tmux capture-pane -J -p)"
else
    content="$(tmux capture-pane -J -p -S -"$limit")"
fi

subcommand="${2:-open}"

items="$(

# remove live numbers and join separated lines with -
echo "$content" |
    perl -0pe 's@-\s*\n\s*\d*\s*@-@g' |
    perl -MList::Util=uniq -e '
    @l=reverse<>; @m=(); $c=0;
    do{
        push @m, $& while m{\b(?:https?|ftp|file|git|ssh):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]\b}g;
        push @m, "http://$1" while m{\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(?::[0-9]{1,5})?(?:/\S+)*)\b}g;
    } for @l;
    printf "%3d  %s\n", ++$c, $_ for uniq(@m)
    '
)"

[[ -z "$items" ]] && exit 0

while read; do
    if [[ "$subcommand" == open ]]; then
        ${ZPWR_OPEN_CMD:-open} "$REPLY"
    elif [[ -n "$ZPWR_COPY_CMD" && -f "$ZPWR_TMUX/google.sh" ]]; then
        printf -- "%s" "$REPLY" | $ZPWR_COPY_CMD
        bash "$ZPWR_TMUX/google.sh" google
    fi
done < <( eval "fzf-tmux $(get_fzf_options)" <<< "$items" | awk '{print $2}' )

exit 0
