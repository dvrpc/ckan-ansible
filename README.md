# ckan-ansible

Ansible project for creating DVRPC's Data Catalog (CKAN).

The Data Catalog is hosted on a Digital Ocean server. During the creation of that server, add one of the system users' ssh keys. These users will then be able to use their corresponding private ssh keys to connect via ssh as the root user. System users are set up in the "users" role.

The ansible.cfg.example files provides some defaults. Copy this file to ansible.cfg (ignored in .gitignore) and, in particular, point to the correct ssh private key to use.

Inventory files for various environments (development/staging/production) are available in the inventories/ directory. Environment-specific variables are stored in these inventories, which are used within the playbook/tasks. For instance, the `dvrpc_branch_repo` specifies which branch of DVRPC's maintained CKAN extensions to use: main for the production environment and development for the staging and development environments (at least as of time of writing).

Staging: https://staging-catalog.cloud.dvrpc.org<br>
Production: https://catalog.dvrpc.org

NOTE: servers must have both IP4 and IP6 enabled.

An initial, one-time playbook has been created to be run as the root user. Run this playbook with the command: `ansible-playbook playbook_init.yml -u root -i inventories/<inventory_file>`. All environments require this to be run first.

It runs the "user" and "hardening" roles, which in general sets up non-root users and hardens the server. These roles are also included in the main playbook that can be run anytime an update is needed.

Then run the main playbook: `ansible-playbook playbook.yml -u <username> -i inventories/<inventory_file>`.

After the initial setup, the playbook_init.yml does not need to be run again, and so you can run playbook.yml as above anytime a change has been made.

### CKAN and Database Upgrades

Two variables control whether we try to update the CKAN version and the database schema:
  - upgrade_ckan
  - upgrade_db

Both are set in the base role's vars file to false. These are mostly dummy values to allow the plays to run (because the variable is used, but we want to only specify it deliberately on the command line).

When needed, set either or both to true on the command line (note that these examples exclude necessary parameters like inventories):
  - `ansible-playbook playbook.yml --extra_vars="upgrade_ckan=true"`
  - `ansible-playbook playbook.yml --extra_vars="upgrade_db=true"`

As they are included in the base role, that tag can also be passed to limit only to that role (`--tag base`).

## DVRPC-maintained extensions

The majority of Data Catalog is stock CKAN or 3rd-party extensions, however we also have several extensions we maintain:
* https://github.com/dvrpc/ckanext-dvrpc_theme
* https://github.com/dvrpc/ckanext-oauth2
* https://github.com/dvrpc/ckanext-customuserprivileges

## Database and Filestore Backup and Restore

Database (both ckan_default and datastore_default) and filestore restore is built into this playbook (in roles/base/tasks/db_files_restore.yaml). Restore will only be done if the associated backups were not previously on the server and have just been uploaded.

Here is the method to create new backups for restoring:

Backup database:
  1. `cd` into the directory where you want to save the backups
  2. `pg_dump -O -F c ckan_default -U ckan_default -h localhost -p 5432 > ckan_default-DATE.pgc` (will be prompted for password)
  3. `pg_dump -O -F c datastore_default -U ckan_default -h localhost -p 5432 > datastore_default-DATE.pgc` (will be prompted for password)

Backup filestore:
  1. `cd /var/lib/ckan`
  2. `tar -czf filestore-DATE.tar.gz default/`

Also see <https://docs.ckan.org/en/2.12/maintaining/database-management.html>.
