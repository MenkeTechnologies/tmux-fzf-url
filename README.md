```
 ██████╗███╗   ███╗██╗   ██╗██╗  ██╗    ███████╗███████╗███████╗    ██╗   ██╗██████╗ ██╗
╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝    ██╔════╝╚══███╔╝██╔════╝    ██║   ██║██╔══██╗██║
   ██║   ██╔████╔██║██║   ██║ ╚███╔╝     █████╗    ███╔╝ █████╗      ██║   ██║██████╔╝██║
   ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗     ██╔══╝   ███╔╝  ██╔══╝     ██║   ██║██╔══██╗██║
   ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗    ██║     ███████╗██║        ╚██████╔╝██║  ██║███████╗
   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚══════╝╚═╝         ╚═════╝ ╚═╝  ╚═╝╚══════╝
```

[![TPM](https://img.shields.io/badge/tpm--support-true-blue)](https://github.com/tmux-plugins/tpm)
[![Awesome](https://img.shields.io/badge/Awesome-tmux-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Eas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC)](https://github.com/rothgar/awesome-tmux)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://MenkeTechnologies.mit-license.org/2018)

> _"The net is vast and infinite."_ -- Ghost in the Shell

**Jack into your tmux pane and rip URLs straight out of the datastream. No mouse. No chrome. Just pure terminal velocity.**

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-fzf-url.gif)

---

### `> SYSTEM REQUIREMENTS_`

Before you flatline, make sure your deck is loaded:

| Dependency | Min Version | Status |
|:--|:--|:--|
| [`fzf`](https://github.com/junegunn/fzf) | any | `REQUIRED` |
| [`bash`](https://www.gnu.org/software/bash/) | `>= 4.0` | `REQUIRED` |

> **Warning:** macOS ships with `bash` `3.2` -- a relic from the old world. Upgrade or get flatlined.

---

### `> INSTALL.exe_`

**// Via [TPM](https://github.com/tmux-plugins/tpm) -- the easy way in**

Drop this line into your tmux config, then hit `prefix + I`:

```tmux
set -g @plugin 'MenkeTechnologies/tmux-fzf-url'
```

**// Manual install -- for those who walk the dark path**

Clone the repo. Source `fzf-url.tmux` in your config. You know the drill.

---

### `> USAGE.dat_`

Hit `prefix + u` and the URL extractor jacks in. Every link in your pane -- HTTP, HTTPS, FTP, SSH, raw IPs -- gets scraped, deduped, and piped through `fzf`.

Pick one. Pick many. They open instantly.

#### `>> CONFIG OVERRIDES`

**Rebind the trigger key:**
```tmux
set -g @fzf-url-bind 'x'
```

**Extend the capture regex -- grab whatever data you need:**
```tmux
# example: snag .txt files from the stream
set -g @fzf-url-extra-filter 'grep -oE "\b[a-zA-Z]+\.txt\b"'
```

**Capture scrollback history -- see beyond the screen:**
```tmux
set -g @fzf-url-history-limit '2000'
```

**Custom fzf options -- shape the interface:**
```tmux
# popup mode (tmux >= 3.2)
set -g @fzf-url-fzf-options '-w 50% -h 50% --multi -0 --no-preview --no-border'
```

---

### `> PROTIPS.log_`

- Select multiple URLs with `TAB` -- open them all in one burst
- Pairs well with [tmux-power](https://github.com/wfxr/tmux-power) for that full neon terminal aesthetic

---

### `> LINKED_NODES_`

- [tmux-power](https://github.com/wfxr/tmux-power) -- statusline that looks like it belongs in Night City
- [tmux-net-speed](https://github.com/wfxr/tmux-net-speed) -- bandwidth monitor for your deck

---

### `> LICENSE_`

```
MIT (c) MenkeTechnologies
```

<sub>_End of line._</sub>
