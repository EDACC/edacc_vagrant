#!/usr/bin/env bash


export DEBIAN_FRONTEND=noninteractive
cat /vagrant/apt_sources.txt > /etc/apt/sources.list

apt-get update
apt-get -q -y install mysql-server
apt-get install -y apache2 libapache2-mod-wsgi git
apt-get install -y python2.7 python-virtualenv python-pip python-dev libmysqlclient-dev
apt-get install -y build-essential gfortran
apt-get install -y r-base
apt-get install -y python-numpy python-pygame python-mysqldb python-rpy2 python-lxml python-scipy python-imaging python-lxml python-sklearn
apt-get install -y tcl tcl-dev tk-dev tk 
apt-get build-dep -y python-mysqldb python-lxml python-rpy2

cd /opt
wget -q https://cran.r-project.org/src/base/R-2/R-2.15.3.tar.gz
tar xvf R-2.15.3.tar.gz
cd R-2.15.3
./configure --prefix=/usr/local --enable-R-shlib --with-tcltk
make rhome=/opt/R-2.15.3 && make install

echo "/usr/local/lib/R/lib/libR.so" > /etc/ld.so.conf.d/R-2.15.3.conf
ldconfig

mkdir -p /srv/edacc_web
git clone https://github.com/EDACC/edacc_web.git /srv/edacc_web

virtualenv /srv/edacc_web_env
ln -s /usr/lib/python2.7/dist-packages/lxml /srv/edacc_web_env/lib/python2.7/site-packages/
ln -s /usr/lib/python2.7/dist-packages/scipy /srv/edacc_web_env/lib/python2.7/site-packages/
ln -s /usr/lib/python2.7/dist-packages/numpy /srv/edacc_web_env/lib/python2.7/site-packages/
ln -s /usr/lib/python2.7/dist-packages/PIL /srv/edacc_web_env/lib/python2.7/site-packages/
ln -s /usr/lib/python2.7/dist-packages/pygame /srv/edacc_web_env/lib/python2.7/site-packages

source /srv/edacc_web_env/bin/activate
pip install -r /vagrant/requirements.txt
pip install mysql-python
pip install scikits.learn

cd /opt 
wget -q https://pypi.python.org/packages/source/r/rpy2/rpy2-2.3.8.tar.gz
tar xvf rpy2-2.3.8.tar.gz
cd rpy2-2.3.8
export LDFLAGS="-Wl,-rpath,/usr/local/lib/R/lib"
python setup.py build --r-home /opt/R-2.15.3 install

cp /vagrant/local_config.py /srv/edacc_web/edacc/local_config.py

git clone https://github.com/EDACC/edacc_gui.git /opt/edacc_gui
mysql -uroot -e "CREATE DATABASE EDACC"
mysql -uroot EDACC < /opt/edacc_gui/src/edacc/resources/edacc.sql

chown -R www-data /srv/edacc_web


export R_HOME=/opt/R-2.15.3
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/R/lib
export R_LIBS_USER=/usr/local/lib/R/site-library/

cd /opt
wget -q https://cran.r-project.org/src/contrib/Archive/surv2sample/surv2sample_0.1-2.tar.gz
R CMD INSTALL surv2sample_0.1-2.tar.gz
wget -q https://cran.r-project.org/src/contrib/Archive/sp/sp_1.0-5.tar.gz
R CMD INSTALL sp_1.0-5.tar.gz
wget -q https://cran.r-project.org/src/contrib/Archive/akima/akima_0.5-8.tar.gz
R CMD INSTALL akima_0.5-8.tar.gz
wget -q https://cran.r-project.org/src/contrib/Archive/spam/spam_0.29-2.tar.gz
R CMD INSTALL spam_0.29-2.tar.gz
wget -q https://cran.r-project.org/src/contrib/Archive/fields/fields_6.7.tar.gz
R CMD INSTALL fields_6.7.tar.gz
wget -q https://cran.r-project.org/src/contrib/Archive/ellipse/ellipse_0.3-7.tar.gz
R CMD INSTALL ellipse_0.3-7.tar.gz
wget -q https://cran.r-project.org/src/contrib/Archive/RColorBrewer/RColorBrewer_1.0-5.tar.gz
R CMD INSTALL RColorBrewer_1.0-5.tar.gz
wget -q https://cran.r-project.org/src/contrib/Archive/cubature/cubature_1.1.tar.gz
R CMD INSTALL cubature_1.1.tar.gz
wget -q https://cran.r-project.org/src/contrib/Archive/np/np_0.40-13.tar.gz
R CMD INSTALL np_0.40-13.tar.gz
rm *.tar.gz

cp /vagrant/edacc_virtualhost /etc/apache2/sites-available/edacc_web.conf
cp /vagrant/edacc_web.wsgi /srv/edacc_web/edacc_web.wsgi

echo "export R_HOME=/opt/R-2.15.3" >> /etc/apache2/envvars
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/R/lib" >> /etc/apache2/envvars
echo "export R_LIBS_USER=/usr/local/lib/R/site-library/" >> /etc/apache2/envvars

a2ensite edacc_web
a2dissite 000-default
service apache2 restart

 
#export R_HOME=/opt/R-2.15.3
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/R/lib
#export R_LIBS_USER=/usr/local/lib/R/site-library/
#python server.py

