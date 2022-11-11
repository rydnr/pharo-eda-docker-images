defineEnvVar BOOTSTRAPPED_FILE "The bootstrapped file" "/backup/mongodb/db/.bootstrapped";
defineEnvVar LOCK_FILE "The lock file" "/backup/mongodb/db/.bootstrap-lock";
overrideEnvVar ENABLE_LOCAL_SMTP "false";
defineEnvVar DUMP_FILE "The backup file, if any" "/backup/mongodb/db/dump.gz";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
