# Install Redmine 3.4.2 on Centos 7
# Based on http://www.redmine.org/projects/redmine/wiki/RedmineInstall/273

# mariadb-server as database
# Puma as webserver
# Apache as reverse proxy

# I recommend adding a redmine user first and then using the redmine user to run the service. 
# Vagrant uses the user vagrant
# adduser redmine

#provision

#update packages
sudo yum -y update

#redmine needs ruby
sudo yum -y install ruby

#mysql
sudo yum -y install mariadb-server
sudo service mariadb restart

#mysq secure installation recommended
#mysql_secure_installation

#redmine dependencies, c bindings for ruby performance
sudo yum -y install gcc mysql-devel ruby-devel rubygems

#SCM binaries
sudo yum -y install svn git

#ImageMagick
sudo yum -y install ImageMagick



#configure database

#start mysql service
sudo service mariadb start

#enable mysql on startup
sudo systemctl enable mariadb

#create database
sudo mysql -u root -e "CREATE DATABASE redmine CHARACTER SET utf8;"
sudo mysql -u root -e "CREATE USER 'redmine'@'localhost' IDENTIFIED BY 'my_password';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'localhost';"




#build

#download redmine using wget from http://www.redmine.org/projects/redmine/wiki/Download
sudo yum -y install wget
wget http://www.redmine.org/releases/redmine-3.4.2.tar.gz

#check md5 2980b80e9acc81c01c06adb86eb4f37d
md5sum redmine-3.4.2.tar.gz

#untar redmine
tar xzfv redmine-3.4.2.tar.gz

#configure database connections
cd redmine-3.4.2/
cp config/database.yml.example config/database.yml

#edit the configuration if needed.
#vi config/database.yml

#redmine uses bundler
sudo gem install bundler

#lib used by bundler to enable imagemagic
sudo yum -y install ImageMagick-devel

#Gemfile.local configured with puma web server and dependencies
cp /vagrant/files/Gemfile.local .

#donwload components and reconfigure the apps

#run every time that we configure the database
/usr/local/bin/bundle install --without development test

#run every time that we configure the database (skips ImageMagic)
#bundle install --without development test rmagick

#Generate session token
/usr/local/bin/bundle exec rake generate_secret_token

#Generate database tables
RAILS_ENV=production bundle exec rake db:migrate

#use full paths in case of path issues
#RAILS_ENV=production /usr/local/bin/bundle exec bin/rake db:migrate

##Load database with test data (if needed)
#export REDMINE_LANG="es"
#RAILS_ENV=production bundle exec rake redmine:load_default_data


#deploy

#create file directories
mkdir -p tmp tmp/pdf public/plugin_assets
cd ..
#move redmine to /opt
sudo mv redmine-3.4.2/ /opt/redmine-3.4.2/
#add symlink
sudo ln -s /opt/redmine-3.4.2 /opt/redmine
#mv files generated outside redmine folder
sudo mv bin/* /opt/redmine/bin


#Configure Redmine

#redmine config
cd /opt/redmine/config
sudo cp configuration.yml.example configuration.yml
#vi configuration.yml


#Webservers


#Example using Webrick testserver

#levanta un server de pruebas para ver que funcione todo en http://10.0.0.19:3000/
#bundle exec rails server webrick -e production
#bundle exec rails server webrick -e production -b 10.0.0.19
#rails server -h
#levantar server puma
#bundle exec puma --environment production
#bundle exec puma --environment production -b tcp://0.0.0.0:9292


#Puma using port 3000

#Configure puma as a service
sudo cp /vagrant/files/puma.service /etc/systemd/system
sudo systemctl daemon-reload

# Enable so it starts on boot
sudo systemctl enable puma.service

# Initial start up
sudo systemctl start puma.service

# Check status
sudo systemctl status puma.service



#Apacha as reverse proxy using port 80

sudo yum -y install httpd

#configuration
sudo cp /vagrant/files/puma-reverseproxy.conf /etc/httpd/conf.d/reverseproxy.conf
#starts service
sudo service httpd start
#enable service on startup
sudo systemctl enable httpd

