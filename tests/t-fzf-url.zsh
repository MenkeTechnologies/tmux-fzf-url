#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Purpose: tmux-fzf-url contract pins.
#####          fzf-url.sh extracts URLs from `tmux capture-pane`
#####          output via a Perl pipeline. fzf-url.tmux wires
#####          `prefix + key` to the extractor. Tests use
#####          tests/lib/extract.sh (a byte-for-byte mirror of the
#####          extraction pipeline) so we can exercise the regex
#####          without needing a live tmux.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    shFile="$pluginDir/fzf-url.sh"
    tmuxFile="$pluginDir/fzf-url.tmux"
    extract="$pluginDir/tests/lib/extract.sh"
}

@test 'both scripts have executable bit set' {
    [[ -x "$shFile" ]]
    assert $? equals 0
    [[ -x "$tmuxFile" ]]
    assert $? equals 0
}

@test 'fzf-url.sh shebang is bash (NOT sh — uses bash process substitution)' {
    # Pin: line ~52 uses < <( … ) which is bash-only. /bin/sh (dash on
    # Debian) would break the picker on every Debian/Ubuntu user.
    local first
    first=$(head -1 "$shFile")
    assert "$first" same_as '#!/usr/bin/env bash'
}

@test 'fzf-url.tmux shebang is bash (NOT sh)' {
    local first
    first=$(head -1 "$tmuxFile")
    assert "$first" same_as '#!/usr/bin/env bash'
}

@test 'fzf-url.sh parses cleanly under bash -n (no syntax errors)' {
    run bash -n "$shFile"
    assert $state equals 0
}

@test 'fzf-url.tmux parses cleanly under bash -n (no syntax errors)' {
    run bash -n "$tmuxFile"
    assert $state equals 0
}

@test 'tests/lib/extract.sh perl pipeline shares dash-continuation regex with fzf-url.sh' {
    # Pin: helper must keep the same s@-...@-@g substitution that
    # fzf-url.sh uses, so test results pin real behaviour.
    grep -qF -- 's@-' "$shFile" && grep -qF -- '@-@g' "$shFile"
    assert $? equals 0
    grep -qF -- 's@-' "$extract" && grep -qF -- '@-@g' "$extract"
    assert $? equals 0
}

@test 'tests/lib/extract.sh shares scheme list with fzf-url.sh (https/ftp/file/git/ssh)' {
    local marker='(?:https?|ftp|file|git|ssh)'
    grep -qF -- "$marker" "$shFile"
    assert $? equals 0
    grep -qF -- "$marker" "$extract"
    assert $? equals 0
}

@test 'tests/lib/extract.sh shares IPv4 fallback regex with fzf-url.sh' {
    local marker='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
    grep -qF -- "$marker" "$shFile"
    assert $? equals 0
    grep -qF -- "$marker" "$extract"
    assert $? equals 0
}

@test 'tests/lib/extract.sh shares List::Util=uniq dedup with fzf-url.sh' {
    grep -qF 'List::Util=uniq' "$shFile"
    assert $? equals 0
    grep -qF 'List::Util=uniq' "$extract"
    assert $? equals 0
}

@test 'URL extractor pulls https, http, ftp, ssh, file URLs from a single line' {
    local out
    out=$(printf '%s\n' 'visit https://github.com/MenkeTechnologies and http://example.com/foo?bar=1 then ftp://ftp.example.com/file.zip then ssh://user@host/path then file:///etc/hosts' | "$extract")
    assert "$out" contains 'https://github.com/MenkeTechnologies'
    assert "$out" contains 'http://example.com/foo?bar=1'
    assert "$out" contains 'ftp://ftp.example.com/file.zip'
    assert "$out" contains 'ssh://user@host/path'
    assert "$out" contains 'file:///etc/hosts'
}

@test 'URL extractor prepends http:// to bare IPv4 (with optional port + path)' {
    # Pin: the IPv4 fallback regex turns 192.168.1.1:8080/x into
    # http://192.168.1.1:8080/x so fzf shows a clickable URL. Without
    # the http:// prefix, $ZPWR_OPEN_CMD gets a bare path and fails.
    local out
    out=$(printf '%s\n' 'server at 10.0.0.5:3000/api and bare 192.168.1.1' | "$extract")
    assert "$out" contains 'http://10.0.0.5:3000/api'
    assert "$out" contains 'http://192.168.1.1'
}

@test 'URL extractor stitches dash-continuation across wrapped lines' {
    # Pin: tmux pane capture wraps long URLs across lines with a dash
    # at the break plus a leading line number on the next line. The
    # first perl pass stitches them back via the dash-continuation
    # substitution. Without it, every wrapped URL would split into
    # two halves and fzf would show garbage.
    local out
    out=$(printf 'visit https://example.com/very-\n42  long\n' | "$extract")
    assert "$out" contains 'https://example.com/very-long'
}

@test 'URL extractor deduplicates repeated URLs (List::Util uniq)' {
    # Pin: same URL appearing 100 times on screen must show once. If
    # List::Util::uniq is dropped, the picker fills with duplicates.
    local count
    count=$(printf 'a https://example.com/x\nb https://example.com/x\nc https://example.com/x\n' | "$extract" | wc -l | tr -d ' ')
    assert "$count" same_as '1'
}

@test 'URL extractor handles URLs containing query strings + fragments' {
    # Pin: real-world URLs with ? & = # must extract intact. The
    # regex char class includes these.
    local out
    out=$(printf 'go to https://example.com/path?a=1&b=2#section\n' | "$extract")
    assert "$out" contains 'https://example.com/path?a=1&b=2#section'
}

@test 'URL extractor preserves order via reverse-then-uniq (newest URL first)' {
    # Pin: @l=reverse<> + uniq preserves first-seen-from-bottom order.
    # Most recent (bottom of pane) URL appears first — UX choice that
    # matches tmux's scroll convention. (Note: regex char class does
    # not consume trailing `/` so URLs end at last alnum.)
    local first
    first=$(printf 'a https://OLD.example.com/x\nb https://NEW.example.com/y\n' | "$extract" | head -1)
    assert "$first" same_as 'https://NEW.example.com/y'
}

@test 'URL extractor returns empty stdout when no URLs are present' {
    # Pin: drives the `[[ -z "$items" ]] && exit 0` short-circuit in
    # the real fzf-url.sh. Without this guard the picker would launch
    # against empty stdin.
    local out
    out=$(printf 'no urls in this content\njust some words\n' | "$extract")
    [[ -z "$out" ]]
    assert $? equals 0
}

@test 'fzf-url.sh log file path uses ZPWR_LOGFILE when set' {
    # Pin: the `exec 2>>` redirect prefers $ZPWR_LOGFILE before falling
    # back to /tmp. Flipping the precedence breaks custom log routing.
    local body
    body=$(cat "$shFile")
    assert "$body" contains 'ZPWR_LOGFILE'
    assert "$body" contains 'exec 2>>'
}

@test 'fzf-url.sh open subcommand invokes \${ZPWR_OPEN_CMD:-open}' {
    # Pin: must honor $ZPWR_OPEN_CMD so Linux users can route to
    # xdg-open. Hardcoded `open` breaks every non-macOS host.
    local body
    body=$(cat "$shFile")
    assert "$body" contains '${ZPWR_OPEN_CMD:-open}'
}

@test 'fzf-url.sh supports copy/google fallback when ZPWR_COPY_CMD set' {
    # Pin: copy + google.sh chain is the secondary subcommand. If the
    # elif drops, "copy" shortcut silently does nothing.
    local body
    body=$(cat "$shFile")
    assert "$body" contains 'ZPWR_COPY_CMD'
    assert "$body" contains 'google.sh'
}

@test 'fzf-url.sh fzf invocation goes through fzf-tmux (NOT bare fzf)' {
    # Pin: fzf-tmux is the popup wrapper. Bare `fzf` would steal the
    # whole pane and conflict with the user's running app.
    local body
    body=$(cat "$shFile")
    assert "$body" contains 'fzf-tmux'
}

@test 'fzf-url.tmux defaults @fzf-url-bind to u (matches docs)' {
    local body
    body=$(cat "$tmuxFile")
    assert "$body" contains "tmux_get '@fzf-url-bind' 'u'"
}

@test 'fzf-url.tmux defaults @fzf-url-history-limit to screen (NOT a number)' {
    # Pin: `screen` means "current visible pane"; a numeric default
    # would silently switch the scrollback window for new users.
    local body
    body=$(cat "$tmuxFile")
    assert "$body" contains "tmux_get '@fzf-url-history-limit' 'screen'"
}

@test 'fzf-url.tmux honors @fzf-url-extra-filter (passes as 2nd positional)' {
    # Pin: extra-filter is the documented hook for users to inject
    # additional URL regexes. The tmux file must pass it as the 2nd
    # arg to fzf-url.sh.
    local body
    body=$(cat "$tmuxFile")
    assert "$body" contains '@fzf-url-extra-filter'
    assert "$body" contains '$extra_filter'
}

@test 'fzf-url.tmux only binds when key is non-empty (graceful disable path)' {
    # Pin: users who set @fzf-url-bind '' want NO bind. The guard
    # preserves that escape hatch.
    local body
    body=$(cat "$tmuxFile")
    assert "$body" contains 'if [[ -n "$key" ]]; then'
    assert "$body" contains 'tmux bind-key'
}

@test 'fzf-url.tmux binds with -b (background) so prompt does not block' {
    # Pin: `run -b` backgrounds the picker. Without -b, the bind would
    # block the tmux command bar until the picker exits.
    local body
    body=$(cat "$tmuxFile")
    assert "$body" contains 'run -b'
}

#--------------------------------------------------------------
# Repo-layout + README contract pins
#--------------------------------------------------------------

@test 'fzf-url.tmux is the documented entrypoint' {
    # The README install snippet sources `fzf-url.tmux`; pin the
    # filename so a future rename surfaces here, not as broken
    # copy-paste lines in users' .tmux.conf.
    [[ -f "$pluginDir/fzf-url.tmux" ]]
    assert $state equals 0
}

@test 'README references fzf-url.tmux entrypoint' {
    run grep -F 'fzf-url.tmux' "$pluginDir/README.md"
    assert $state equals 0
}

@test 'fzf-url.sh has executable bit set' {
    # The .tmux script execs `fzf-url.sh` — must be +x for the
    # exec to succeed under tmux's strict mode (no implicit
    # `sh` interpreter on the spawn).
    [[ -x "$pluginDir/fzf-url.sh" ]]
    assert $state equals 0
}
