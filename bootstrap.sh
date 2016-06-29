#!/bin/bash
PROJECT="djangotest"


sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#......................................
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y \
    git \
    build-essential \
    python-dev \
    python3.4 \
    python3.4-dev \
    python-pip \
    python3-pip

sudo apt-get install -y \
    postgresql-9.5 \
    postgresql-server-dev-9.5 \
    libpq-dev \
    postgresql-contrib

sudo pip install --upgrade \
    pip \
    virtualenv

sudo pip install \
    virtualenvwrapper

sudo pip install --upgrade \
    virtualenvwrapper

echo '....................Install OK'

#..
sudo echo " " >> /etc/postgresql/9.5/main/postgresql.conf
sudo echo "listen_addresses = '*'" >> /etc/postgresql/9.5/main/postgresql.conf
sudo sed -i "/^# Database administrative login by Unix domain socket/a local    all  django   md5\n" /etc/postgresql/9.5/main/pg_hba.conf
sudo sed -i "/^# IPv4 local connections/a host all all 0.0.0.0/0 trust\n" /etc/postgresql/9.5/main/pg_hba.conf

sudo /etc/init.d/postgresql restart
echo '....................postgresql OK'
#..

sudo -u postgres createdb vagrant
sudo -u postgres psql -c "create user vagrant with superuser password '';"
sudo -u postgres psql -c "create user django with password 'django';"
#...
sudo -u postgres createdb $PROJECT
sudo -u postgres psql -c "grant all privileges on database $PROJECT to django;"
echo '....................$PROJECT base OK'
#...

#...
touch /home/vagrant/.bashrc
echo " " >> /home/vagrant/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/vagrant/.bashrc

# ...mkvirtualenv
sudo -u vagrant bash -c "
    mkdir -p /vagrant/.env
    ln -s /vagrant/.env /home/vagrant/.virtualenvs
    export HOME=/home/vagrant/
    source /usr/local/bin/virtualenvwrapper.sh
    mkvirtualenv -p /usr/bin/python3 $PROJECT
"
# ...requirements
sudo -u vagrant bash -c "
    export HOME=/home/vagrant/
    source /vagrant/.env/$PROJECT/bin/activate     
    pip install -r /vagrant/requirements.txt    
"

# ....startproject
sudo -u vagrant bash -c "
    export HOME=/home/vagrant/
    source /vagrant/.env/$PROJECT/bin/activate
    mkdir /vagrant/$PROJECT
    django-admin startproject $PROJECT /vagrant/$PROJECT
"
# ...set system settings
sed -i "s/BASE_DIR\ =\ os.path.dirname(os.path.dirname(os.path.abspath(__file__)))/BASE_DIR\ =\ os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))/" /vagrant/$PROJECT/$PROJECT/settings.py
sed -i "s/LANGUAGE_CODE\ =\ 'en-us'/LANGUAGE_CODE\ =\ 'ru-RU'/" /vagrant/$PROJECT/$PROJECT/settings.py
sed -i "s/TIME_ZONE\ =\ 'UTC'/TIME_ZONE\ =\ 'Europe\/Moscow'/" /vagrant/$PROJECT/$PROJECT/settings.py

# ...set db
sed -i "s/'ENGINE':\ 'django.db.backends.sqlite3',/\
        'ENGINE':\ 'django.db.backends.postgresql_psycopg2',\
        /" /vagrant/$PROJECT/$PROJECT/settings.py

sed -i "s/'NAME':\ os.path.join(BASE_DIR,\ 'db.sqlite3'),/\
        'NAME':\ '$PROJECT',\
        \n'USER':\ 'django',\
        \n'PASSWORD':\ 'django',\
        \n'HOST':\ '',\
        \n'PORT':\ '',\
        /" /vagrant/$PROJECT/$PROJECT/settings.py

# ...set logging
echo '' >> /vagrant/$PROJECT/$PROJECT/settings.py
echo '# Logging files' >> /vagrant/$PROJECT/$PROJECT/settings.py
echo '' >> /vagrant/$PROJECT/$PROJECT/settings.py    
echo "LOG_FILE = os.path.join(BASE_DIR, 'logs/django.log')" >> /vagrant/$PROJECT/$PROJECT/settings.py    
# ..
echo '' >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "LOGGING = {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    'version': 1," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    'disable_existing_loggers': False," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    'formatters': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        'standard': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'format' : '[%(asctime)s] %(levelname)s [%(name)s:%(lineno)s] %(message)s'," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'datefmt' : '%d/%b/%Y %H:%M:%S'" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        'simple': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'format': '%(levelname)s %(message)s'" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    'filters': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        'require_debug_true': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            '()': 'django.utils.log.RequireDebugTrue'," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    }, " >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    'handlers': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        'console': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'level': 'DEBUG'," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'filters': ['require_debug_true']," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'class': 'logging.StreamHandler'," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'formatter': 'simple'" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        'file': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'level': 'DEBUG'," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'class': 'logging.FileHandler'," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'filename': LOG_FILE," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    'loggers': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        '$PROJECT': {" >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'handlers': ['console','file']," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'level': 'DEBUG'," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'propagate': True," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "            'formatter': 'standard'," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "        }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "    }," >> /vagrant/$PROJECT/$PROJECT/settings.py
echo "}" >> /vagrant/$PROJECT/$PROJECT/settings.py

# ...migrate
sudo -u vagrant bash -c "
    export HOME=/home/vagrant/
    source /vagrant/.env/$PROJECT/bin/activate     
    /vagrant/$PROJECT/manage.py migrate
"
#
LOGSDIR="/vagrant/logs/"
if [ ! -d "$LOGSDIR" ];then
    mkdir $LOGSDIR
fi
echo '' > $LOGSDIR/django.log
# ..
STATICDIR="/vagrant/static/"
if [ ! -d "$STATICDIR" ];then
    mkdir $STATICDIR
fi
#...
sudo apt-get autoremove
sudo apt-get autoclean
echo 'YaHoo !!!'

exit 0


# cd /vagrant/registrar && workon registrar && ./manage.py runserver 0.0.0.0:8000
#./

