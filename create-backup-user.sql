# Create a MySQL user with limited privileges for backup purposes.
# This isn't strictly necessary on a local machine - you could just use the root
# MySQL user in the backup script.
# ==============================================================================

# Get a MySQL/MariaDB prompt:
mysql -u root -p

# In the MySQL shell enter:
CREATE USER 'backup_user'@'localhost'
IDENTIFIED BY 'randomlongpassword123';
GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup_user'@'localhost';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'backup_user'@'localhost';
