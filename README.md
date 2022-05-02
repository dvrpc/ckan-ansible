# ckan-ansible

Ansible project for creating DVRPC's Data Catalog (CKAN) - internal and public.

There are three inventory files in the inventories/ folder matching the target system - development, internal, and public.

## Internal

The internal CKAN instance is located on a virtual machine at DVRPC. It is only accessible from within DVRPC and to the public instance for harvesting public datasets.

### Initial Setup

The ansible project is set up to be run locally. These are the steps to install everything on a newly provisioned Ubuntu 20.04 virtual machine, after logging in as a non-root user:
  1. `sudo apt update && sudo apt upgrade`
  2. Install ansible from ansible ppa (Ubuntu 20.04 comes with 2.9, and we need at least 2.11 for some stuff):
    a. `sudo apt install software-properties-common`
    b. `sudo add-apt-repository --yes --update ppa:ansible/ansible`
    c. `sudo apt install ansible`
  3. Clone the repo: `git clone https://github.com/dvrpc/ckan-ansible.git`.
  4. Created /root/.ssh/config and add the following to it, so we use ssh from behind DVRPC firewall (required for some private repos):
    ```
    Host github.com
      Hostname ssh.github.com
      Port 443
      User git
    ```
  5. Cd into the ckan-ansible repo. Create file vault_password. Only line in the file is the vault password for the project.
  6. Run the playbook: `sudo ansible-playbook playbook.yml -u kwarner -i inventories/internal.yml` (user could also be "jstrangfeld")

### Updates

Following the initial setup, pulling the repo and running the playbook are the only required steps for subsequent runs. From the non-root user's home folder:
  1. `cd ckan-ansible`
  2. `git pull`
  3. `sudo ansible-playbook playbook.yml -u kwarner -i inventories/internal.yml`

All in one: `cd ckan-ansible && git pull && sudo ansible-playbook playbook.yml -u kwarner -i inventories/internal.yml`.

## Public

The public version of the Data Catalog is hosted on a Digital Ocean server. During the creation of that server, add one of our users' ssh keys (Kris Warner or Jesse Strangfeld). These users will then be able to use their corresponding private ssh keys to connect via ssh as the root user.

An initial, one-time playbook has been created to be run as the root user. Run this playbook with the command: `ansible-playbook playbook_init.yml -u root -i inventories/public.yml`.

It runs the "user" and "hardening" roles, which in general sets up non-root users and hardens the server. These roles are also included in the main playbook that can be run anytime an update is needed.

Now run the main playbook: `ansible-playbook playbook.yml -u [kwarner or jstrangfeld] -i inventories/public.yml`.

After the initial setup, the playbook_init.yml does not need to be run again, and so you can run playbook.yml as above anytime a change has been made.
