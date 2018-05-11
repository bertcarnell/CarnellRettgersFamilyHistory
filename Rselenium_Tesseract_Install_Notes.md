<!-- Copyright (c) 2018 Robert Carnell -->

# Directions to setup Selenium, RSelenium, Docker, and Tesseract for Genealogy

### install the necessary packages

#### Ubuntu and RaspberryPi

```
# prepare
sudo apt-get update
sudo apt-get upgrade
# for tesseract
sudo apt-get install libleptonica-dev
sudo apt-get install g++ autoconf automake libtool autoconf-archive
sudo apt-get install pkg-config
sudo apt-get install libpng-dev libjpeg8-dev libtiff5-dev
sudo apt-get install zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev
sudo apt-get install tesseract-ocr libtesseract-dev tesseract-ocr-deu
# for R packages and R
sudo apt-get install libssl-dev libxml2-dev docker libxt-dev libcurl4-openssl-dev
sudo apt-get install texlive default-jdk default-jre
```

### Checkout tesseract for the German Fraktur script

```
mkdir ~/repositories/tessdata
git clone https://github.com/tesseract-ocr/tessdata.git ~/repositories/tessdata
cd ~/repositories/tessdata
git checkout 3.04.00
sudo cp deu_frak.traineddata /usr/share/tesseract-ocr/tessdata

tesseract --list-langs # should include deu_frak
```

### Checkout the genealogy repository

```
mkdir ~/repositories/CarnellRettgersFamilyHistory
git clone https://github.com/bertcarnell/CarnellRettgersFamilyHistory.git ~/repositories/CarnellRettgersFamilyHistory
```

### Build R to ensure the latest version is installed

```
svn checkout https://svn.r-project.org/R/branches/R-3-3-branch ~/repositories/R3.3.patched
cd ~/repositories/R3.3.patched
./tools/rsync-recommended
mkdir ~/repositories/R3.3.patched.build
cd ~/repositories/R3.3.patched.build
../R3.3.patched/configure
make # this will take multiple hours
make check # this is optional and is most necessary when building for a new architecture
sudo make install
```

### Install the necessary R packages

```
sudo R
install.packages(c("rvest","lubridate"), repos="https://cloud.r-project.org")
install.packages(c("XML","caTools"), repos="https://cloud.r-project.org")
install.packages(c("rappdirs","yaml","assertthat","semver","subprocess"), repos="https://cloud.r-project.org")

# Download package tarball from CRAN archive since it is archived temporarily
url <- "https://cran.r-project.org/src/contrib/Archive/RSelenium/RSelenium_1.7.1.tar.gz"
url2 <- "https://cran.r-project.org/src/contrib/Archive/wdman/wdman_0.2.2.tar.gz"
url3 <- "https://cran.r-project.org/src/contrib/Archive/binman/binman_0.1.0.tar.gz"

pkgFile <- "RSelenium_1.7.1.tar.gz"
pkgFile2 <- "wdman_0.2.2.tar.gz"
pkgFile3 <- "binman_0.1.0.tar.gz"
download.file(url = url, destfile = pkgFile)
download.file(url = url2, destfile = pkgFile2)
download.file(url = url3, destfile = pkgFile3)

# Install package
install.packages(pkgs=pkgFile3, type="source", repos=NULL)
install.packages(pkgs=pkgFile2, type="source", repos=NULL)
install.packages(pkgs=pkgFile, type="source", repos=NULL)

# Delete package tarball
unlink(pkgFile)
unlink(pkgFile2)
unlink(pkgFile3)
```

### Get docker

#### Get docker for raspbery pi

```
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# clone docker image repos for raspberry pi
mkdir ~/repositories/docker-selenium
git clone https://github.com/SeleniumHQ/docker-selenium.git ~/repositories/docker-selenium
nano Base/Dockerfile
# make these changes
-RUN  echo "deb http://archive.ubuntu.com/ubuntu xenial main universe\n" > /etc/apt/sources.list \
+RUN  echo "deb http://ports.ubuntu.com xenial main universe\n" > /etc/apt/sources.list \
-&& echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main universe\n" >> /etc/apt/sources.list \
+&& echo "deb http://ports.ubuntu.com xenial-updates main universe\n" >> /etc/apt/sources.list \
-&& echo "deb http://security.ubuntu.com/ubuntu xenial-security main universe\n" >> /etc/apt/sources.list
+&& echo "deb http://ports.ubuntu.com xenial-security main universe\n" >> /etc/apt/sources.list
-&& sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security
+&& sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

nano NodeFirefox/Dockerfile.txt
-&& rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
-&& wget --no-verbose -O /tmp/firefox.tar.bz2 $FIREFOX_DOWNLOAD_URL \
-&& apt-get -y purge firefox \
-&& rm -rf /opt/firefox \
-&& tar -C /opt -xjf /tmp/firefox.tar.bz2 \
-&& rm /tmp/firefox.tar.bz2 \
-&& mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
-&& ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox
-&& wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux64.tar.gz \
+&& wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-arm7hf.tar.gz \
  
# then run this
# remove all images
sudo docker system prune -a
sudo docker images -a
VERSION=local sudo make base
# chrome does not have a armhf install
VERSION=local sudo make firefox
VERSION=local sudo make standalone_firefox

# remove untagged images
sudo docker rmi $(sudo docker images -a | grep "^<none>" | awk '{ print $3 }')

sudo docker run -it --entrypoint /bin/bash selenium/standalone-firefox:3.11.0-dysprosium
/usr/bin/firefox --version
exit
```

#### Get docker for Ubuntu

```
sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
	 
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
 sudo apt-get install docker-ce
```
 
### Start Docker
 
#### RaspberryPi

```
sudo docker run -d -p 4444:4444 -v /dev/shm:/dev/shm selenium/standalone-firefox:3.11.0-dysprosium
```

#### ubuntu

```
sudo docker run -d -p 4444:4444 -v /dev/shm:/dev/shm -v /home/pi/Downloads:/home/seluser/Downloads \
--name chrome_docker selenium/standalone-chrome:3.11.0-dysprosium
sudo docker ps -a
```

### Other Commands

```
#remove stopped containers
docker rm $(docker ps -a -q)

# view images
eog filename.gif

# user terminal
gnome-terminal
```
