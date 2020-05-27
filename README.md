# dotfiles

Setup and configure development environment on Ubuntu machines.

Based off of https://github.com/mathiasbynens/dotfiles and https://github.com/alrra/dotfiles

## Using Git and the bootstrap script 

You can clone the repository wherever you want. The bootstrapper script
will pull in the latest version and copy the files to your home folder.

```shell
git clone https://github.com/gruis/dotfiles.git && cd dotfiles && ./bootstrap.sh 
```

To update, cd into your local dotfiles repository and then:

```shell
./bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```shell
bootstrap.sh --force
```

## Git-free install

To install these dotfiles without Git:

```shell
bash -c "$(wget -qO - https://raw.githubusercontent.com/gruis/dotfiles/master/install/setup.sh)"
```

### Unattended Install

```shell
bash -c "$(wget -qO - https://raw.githubusercontent.com/gruis/dotfiles/master/install/setup.sh)" -- --yes
```

To update later on, just run the same command
