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
