bind -M insert \cA beginning-of-line
bind -M insert \cE end-of-line

bind -M insert \ck accept-autosuggestion

bind -M insert -k up history-prefix-search-backward
bind -M insert \cP history-prefix-search-backward

bind -M insert -k down history-prefix-search-forward
bind -M insert \cN history-prefix-search-forward
