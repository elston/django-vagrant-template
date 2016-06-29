#!/bin/bash
PROJECT="djangotest"
name='auth_user'
# ....
vagrant up
vagrant ssh -c "
    export HOME=/home/vagrant/
    source /vagrant/.env/$PROJECT/bin/activate     
    /vagrant/$PROJECT/manage.py createsuperuser  
    /vagrant/$PROJECT/manage.py runserver 0.0.0.0:8000
    psql -d $PROJECT -t -A -F',' -c 'select row_to_json(t) from (select * from ${name,,}) as t;' > /vagrant/__d__$name.json    
"
vagrant halt
