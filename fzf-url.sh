#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 12:12
#===============================================================================
exec &>> "${ZPWR_LOGFILE:-/tmux-$(id -u)-fzf-url.log}"

get_fzf_options() {
    local fzf_options pre
    pre='x=$(echo {} | awk "{print \$2}"); curl -fsSL $x'
    local fzf_default_options="-d 35% -m -0 --no-border --preview '$pre'"
    fzf_options="$(tmux show -gqv '@fzf-url-fzf-options')"
    [[ -n "$fzf_options" ]] && echo "$fzf_options" || echo "$fzf_default_options"
}


limit='screen'
(( $# >= 1 )) && limit="$1"

if [[ $limit == 'screen' ]]; then
    content="$(tmux capture-pane -J -p)"
else
    content="$(tmux capture-pane -J -p -S -"$limit")"
fi

items="$(

echo "$content" | perl -MList::Util=uniq -e '
@l=reverse<>; @m=();
for(@l){
    push (@m, $&) while m{(?:https?|ftp|file|git|ssh):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]}g;
    push (@m, "http://$2") while m{(^|\s)([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(?::[0-9]{1,5})?(?:/\S+)*)}g;
}
$c=0;
for (uniq @m){
printf "%3d  %s\n", ++$c, $_
}'
)"

[[ -z "$items" ]] && exit 0


while read; do
    ${ZPWR_OPEN_CMD:-open} "$REPLY"
done < <( eval "fzf-tmux $(get_fzf_options)" <<< "$items" | awk '{print $2}' )

exit 0
