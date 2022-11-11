defineEnvVar MONGODB_DUMP_FOLDER OPTIONAL "The folder storing the generated dump file" "/backup/mongodb/dumps";
defineEnvVar MONGODB_HOST OPTIONAL "The MongoDB host" "localhost";
defineEnvVar MONGODB_USER OPTIONAL "The MongoDB user" "${ADMIN_USER}";
defineEnvVar MONGODB_PASSWORD OPTIONAL "The password of the MongoDB user" "${ADMIN_PASSWORD}";
defineEnvVar MONGODB_AUTHENTICATION_DATABASE OPTIONAL "The authentication database" "admin";
defineEnvVar MONGODB_AUTHENTICATION_MECHANISM "The authentication mechanism" "SCRAM-SHA-256";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
