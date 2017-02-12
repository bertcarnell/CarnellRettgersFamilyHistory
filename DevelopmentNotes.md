Directions to setup Gramps on Ubuntu for Development

```
# update the system
sudo apt-get update
sudo apt-get upgrade

# set up git if not previously set up
git config --get user.name
git config --get user.email
git config --global user.name "bertcarnell"
git config --global user.email bertcarnell@gmail.com
git config --global core.autocrlf input
head ~/.ssh/id_rsa.pub
# copy public key to Github settings
# check the communication
ssh -T git@github.com

# checkout the repository
git clone git@github.com:gramps-project/gramps.git Gramps
cd Gramps
git checkout maintenance/gramps42
git pull

# install pycharm if not already done
echo "deb http://archive.getdeb.net/ubuntu $(lsb_release -cs)-getdeb apps" | sudo tee /etc/apt/sources.list.d/getdeb-apps.list
wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install pycharm

# install python dependencies
sudo apt-get install python3
sudo apt-get install python3-pip 
sudo apt-get install libdb5.3
sudo apt-get install libdb5.3-dev 
pip3 install bsddb3

# run Gramps
python3 Gramps.py 
# or from pycharm
File -> Settings
Project:Gramps -> Project Interpreter
change to /usr/bin/python3.4
right click on Gramps.py and run or debug
```
