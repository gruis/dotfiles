Install
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/gruis/dotfiles/master/bash-vm/bootstrap.sh)" -- --github gruis
```

Stages (optional)
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/gruis/dotfiles/master/bash-vm/bootstrap.sh)" -- \
  --github gruis \
  --stage shell-extras
```
Note: oh-my-posh requires a Nerd Font in your local terminal. The stage installs Hack Nerd Font on the server, but you must select it locally (e.g., "Hack Nerd Font") for glyphs to render.

Multiple stages
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/gruis/dotfiles/master/bash-vm/bootstrap.sh)" -- \
  --github gruis \
  --stage shell-extras \
  --stage docker
```

List stages
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/gruis/dotfiles/master/bash-vm/bootstrap.sh)" -- --list-stages
```
