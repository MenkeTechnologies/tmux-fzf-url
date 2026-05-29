#!/usr/bin/env bash
# Test helper: exposes the URL-extraction pipeline from fzf-url.sh in
# isolation so unit tests can exercise the perl regexes without
# needing a live tmux. The body MUST stay byte-identical to the
# pipeline in fzf-url.sh — if it drifts, the tests stop pinning the
# real behaviour. Reads input on stdin, prints uniq'd URLs on stdout.
perl -0pe 's@-\s*\n\s*\d*\s*@-@g' |
perl -MList::Util=uniq -e '
@l=reverse<>; @m=();
do{
    push @m, $& while m{\b(?:https?|ftp|file|git|ssh):/?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]\b}g;
    push @m, "http://$1" while m{\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(?::[0-9]{1,5})?(?:/\S+)*)\b}g;
} for @l;
printf "%s\n", $_ for uniq(@m);
'
