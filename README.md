# ckan-ansible
Ansible project for creating DVRPC's Data Catalog (CKAN).

The Data Catalog is hosted on a Digital Ocean server. During the creation of that server, add one of the system users' ssh keys (Kris Warner or Jesse Strangfeld). These users will then be able to use their corresponding private ssh keys to connect via ssh as the root user. System users are set up in the "users" role.

Inventory files for various environments (development/staging/production) are available in the inventories/ directory. Environment-specific variables are stored in these inventories, which are used within the playbook/tasks. For instance, the `dvrpc_branch_repo` specifies which branch of DVRPC's maintained CKAN extensions to use: main for the production environment and development for the staging and development environments (at least as of time of writing).

Staging: https://staging-catalog.cloud.dvrpc.org<br>
Production: https://catalog.dvrpc.org

NOTE: servers must have both IP4 and IP6 enabled.

An initial, one-time playbook has been created to be run as the root user. Run this playbook with the command: `ansible-playbook playbook_init.yml -u root -i inventories/<inventory_file>`. All environments require this to be run first.

It runs the "user" and "hardening" roles, which in general sets up non-root users and hardens the server. These roles are also included in the main playbook that can be run anytime an update is needed.

After setting the variable `update_ckan` to the appropriate setting (`true` the first time you install CKAN, but then generally `false` unless you are explicitly attempting to update the CKAN version), run the main playbook: `ansible-playbook playbook.yml -u <username> -i inventories/<inventory_file>`. 

After the initial setup, the playbook_init.yml does not need to be run again, and so you can run playbook.yml as above anytime a change has been made.

## DVRPC-maintained extensions

The majority of Data Catalog is stock CKAN or 3rd-party extensions, however we also have several extensions we maintain:
* https://github.com/dvrpc/ckanext-dvrpc_theme
* https://github.com/dvrpc/ckanext-oauth2
* https://github.com/dvrpc/ckanext-dvrpc_gis_harvester
* https://github.com/dvrpc/ckanext-customuserprivileges

## Database and Filestore Backup and Restore

Here is the process for fully backing up and restoring CKAN data (including user data and any oauth tokens). See also <https://docs.ckan.org/en/2.9/maintaining/database-management.html>.

Backup database:
  1. Clear any harvested datasets first via the web interface - there's no need to back these up or restore them
  2. `cd` into the directory where you want to save the backups
  3. `pg_dump -O -F c ckan_default -U ckan_default -h localhost -p 5432 > ckan_default-DATE.pgc` (will be prompted for password)
  4. `pg_dump -O -F c datastore_default -U ckan_default -h localhost -p 5432 > datastore_default-DATE.pgc` (will be prompted for password)

Backup filestore:
  1. `cd /var/lib/ckan`
  2. `tar -czf filestore-DATE.tar.gz default/`

Restore database:
  1. Do this locally first on a test machine so as to ensure the integrity of the data - the process involves wiping everything from the existing database
  2. `cd` into directory where you placed/uploaded the backups
  3. Activate the CKAN virtual environment: `source /usr/lib/ckan/default/bin/activate`
  4. Wipe the existing database: `ckan -c /etc/ckan/default/ckan.ini db clean`
  5. `sudo -u postgres pg_restore --clean --if-exists -d ckan_default < ckan_default-DATE.pgc`
  6. `sudo -u postgres pg_restore --clean --if-exists -d datastore_default < datastore_default-DATE.pgc`
  7. rebuild the solr index: `ckan -c /etc/ckan/default/ckan.ini tracking update && ckan -c /etc/ckan/default/ckan.ini search-index rebuild -r`

Restore Filestore:
  1. `cd var/lib/ckan`
  2. Make a copy of the local directory: `mv default/ default-bk/`
  3. untar the archive: `tar -xf filestore-DATE.tar.gz`
