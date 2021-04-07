Role Name: mysql_install
=========

This ansible role can help you to automate the mysql installation tasks.
What it will do:

- Check whether mysqld is existing on target.
- If not, do a fresh install.
- If mysqld is installed already, compare versions between existing and expected.
- If existing >= expected, abort the playbook.
- If existing < expected, install and upgrade to expected version.
- It will also check mysql root password.
- If the defined root credential does not work, abort the playbook.
- Post installation steps include apply mysql config, secure mysql installation, create db and db users.

Requirements
------------

- Taget OS: RHEL 7 - 64 bit
- MySQL version: 5.7.x
- Target machine must be able to fetch packages from Internet - <http://repo.mysql.com>

Role Variables
--------------

- **mysql_version**: expected mysql version to be installed.
- **mysql_config_file**: specific mysql config for your app. You can place your own mysql config file under *<role_path>/templates/<your_mysql_config_template>* then then adjust this var accordingly.
- **dba**: database admin username, default is "root".
- **dba_pass**: password of db admin.
- **app_db_name**: app db name.
- **app_db_users**: db user to access your app db with password and proper privileges.

Example Playbook
----------------

*Sample host_vars/group_vars*:

``` python
mysql_version: "5.7.28"
mysql_config_file: "my.cnf_5.7.j2"

dba: root
dba_pass: <encrypted>

 app_db_users:
  - name: "app_db"
    password: <encrypted>
    priv: "app_db.*:ALL"
    host: "%"
```

*Sample playbook*:

``` python
- hosts: mysql_server
  remote_user: root
  roles:
   - {role: mysql_install, tags: ['mysql_install']}

```

*Sample commands*:

``` bash
ansible-playbook -i inventory/hosts playbook.yml -v --ask-vault-pass
```

*Variations:*

- In order to downgrade or reinstall, please set or run with **--extra-vars "check_existing=false remove_existing=true"**.
- In order to overwrite mysql root password, please set or run with **--extra-vars "check_mysql_root=false reset_mysql_root=true"**.
