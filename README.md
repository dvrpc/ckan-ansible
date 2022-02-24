# ckan-ansible

Ansible project for creating DVRPC's Data Catalog (CKAN) - internal and public.

There are three inventory files in the inventories/ folder matching the target system - development, internal, and public.

## Initial Setup

The public version of the Data Catalog is hosted on a Digital Ocean server. During the creation of that server, add one of our users' ssh keys (Kris Warner or Jesse Strangfeld). These users will then be able to use their corresponding private ssh keys to connect via ssh as the root user.

An initial, one-time playbook has been created to be run as the root user. Run this playbook with the command: `ansible-playbook playbook_init.yml -u root -i inventories/public.yml`.

It runs the "user" and "hardening" roles, which in general sets up non-root users and hardens the server. These roles are also included in the main playbook that can be run anytime an update is needed.

Now run the main playbook: `ansible-playbook playbook.yml -u [kwarner or jstrangfeld] -i inventories/public.yml`.

After the initial setup, the playbook_init.yml does not need to be run again, and so you can run playbook.yml as above anytime a change has been made.
