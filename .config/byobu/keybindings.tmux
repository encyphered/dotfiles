unbind-key -n C-a
set -g prefix ^A
set -g prefix2 F12
bind a send-prefix

bind-key S split-window -v
bind-key | split-window -h
bind-key C send-keys C-l

unbind k
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

unbind w
