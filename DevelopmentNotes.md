<!-- Copyright (c) 2018 Robert Carnell -->

# Directions to setup Gramps on Ubuntu for Development

### Update the system

```
sudo apt-get update
sudo apt-get upgrade
```

### Set up git if not previously set up

```
git config --get user.name
git config --get user.email
git config --global user.name "bertcarnell"
git config --global user.email bertcarnell@gmail.com
git config --global core.autocrlf input
head ~/.ssh/id_rsa.pub
# copy public key to Github settings on www.github.com
# check the communication
ssh -T git@github.com
```

### Checkout the repository

```
git clone git@github.com:gramps-project/gramps.git Gramps
cd Gramps
git checkout maintenance/gramps50
git pull
```

### Install [pycharm](https://www.jetbrains.com/pycharm/)

#### Before Ubuntu 16.04

```
echo "deb http://archive.getdeb.net/ubuntu $(lsb_release -cs)-getdeb apps" | sudo tee /etc/apt/sources.list.d/getdeb-apps.list
wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install pycharm
# to start pycharm
pycharm
```

#### After Ubuntu 16.04

```
sudo snap install pycharm-community --classic
# to start pycharm
pycharm-community 
```

### Install python dependencies

```
sudo apt-get install python3
sudo apt-get install python3-pip 
sudo apt-get install libdb5.3
sudo apt-get install libdb5.3-dev 
pip3 install bsddb3
```

Follow directions in Gramps README file to install latest dependencies.

### Methods to run Gramps:

#### Run installed version

```
python3 setup.py build
sudo python3 setup.py install
gramps
```

#### Run Gramps with python

```
python3 Gramps.py
```

#### Run from pycharm

- File -> Settings
- Project:Gramps -> Project Interpreter
- change to /usr/bin/python3.4
- right click on Gramps.py and run or debug

# Git Reminders

### Working with a forked repository:

1. create the fork on Github
2. clone the repository on your system

```
git clone https://github.com/bertcarnell/gramps.git ~/repositories/grampsfork
cd ~/repositories/grampsfork
git pull
```

### List the current configured remote repository

```
git remote -v
```

output

```
origin	git@github.com:bertcarnell/gramps.git (fetch)
origin	git@github.com:bertcarnell/gramps.git (push)
upstream	git://github.com/gramps-project/gramps.git (fetch)
upstream	git://github.com/gramps-project/gramps.git (push)
```

if you don't see the upstream remote, then add it:

```
git remote add upstream https://github.com/gramps-project/gramps.git
```

Get the upstream branches

```
git fetch upstream
```

Checkout the branch you want

```
git checkout master
```

Merge the upstream changes into the local changes without losing local changes

```
git merge upstream/master
```

Push the merge back up to the fork on github

```
git push
```

Check github.  You should see "This branch is even with gramps-project:master

### Check out a new branch from the upstream remote

Modify the config file to see all branches

```
gedit .git/config &
```

This text in the file:

```
[remote "upstream"]
	url = git://github.com/gramps-project/gramps.git
	fetch = +refs/heads/master:refs/remotes/upstream/master
```

should be

```
[remote "upstream"]
	url = git://github.com/gramps-project/gramps.git
	fetch = +refs/heads/*:refs/remotes/upstream/*
```

```
git fetch upstream
git checkout -b maintenance/gramps50 upstream/maintenance/gramps50
git push -u origin maintenance/gramps50
```
