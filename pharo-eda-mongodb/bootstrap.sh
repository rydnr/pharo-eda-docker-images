#!/usr/bin/env dry-wit
# (c) 2017-today Automated Computing Machinery, S.L.
#
#    This file is part of pharo-eda-docker-images.
#
#    pharo-eda-docker-images is free software: you can redistribute it and/or
#    modify it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    pharo-eda-docker-images is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with pharo-eda-docker-images.
#    If not, see <http://www.gnu.org/licenses/>.
#
# mod: pharo-eda-mongodb/pharo-eda-bootstrap.sh
# api: public
# txt: Bootstraps a local MongoDB server for PharoEDA.

DW.import mongodb-bootstrap

setDebugEnabled

# fun: main
# api: public
# txt: Bootstraps a local MongoDB server for PharoEDA.
# txt: Returns 0/TRUE always, but can exit in case of error.
# use: main
function main() {
    mongodbMigrate \
        "${SQ_SERVICE_USER}" \
        "${SQ_SERVICE_GROUP}" \
        "${DATABASE_FOLDER}" \
        "${PERMISSIONS_FOLDER}" \
        "${CONFIG_FILE}" \
        "${AUTHENTICATION_DATABASE}" \
        "${AUTHENTICATION_DATABASE}" \
        "${AUTHENTICATION_MECHANISM}" \
        "${ADMIN_USER_NAME}" \
        "${ADMIN_USER_PASSWORD}" \
        "${ENABLE_FREE_MONITORING}" \
        "${BACKUP_ROLE_NAME}" \
        "${BACKUP_ROLE_SPEC}" \
        "${BACKUP_USER_NAME}" \
        "${BACKUP_USER_PASSWORD}" \
        ${START_TIMEOUT} \
        ${START_CHECK_INTERVAL} \
        "${BOOTSTRAP_FILE}" \
        "${LOCK_FILE}"
}

# fun: mongodb_patch
# api: public
# txt: Patches the MongoDB instance. It's actually a hook of mongodb-bootstrap.mongodbMigrate;
# txt: Returns 0/TRUE always, but can exit in case of error.
# use: mongodb_patch;
function mongodb_patch() {
    echo -n ""
}

# Script metadata
setScriptDescription "Bootstraps a local MongoDB server for PharoEDA."

# env: DATABASE_FOLDER: The db folder. Defaults to /backup/mongodb/db.
defineEnvVar DATABASE_FOLDER MANDATORY "The db folder" "/backup/mongodb/db"
# env: PERMISSIONS_FOLDER: The folder whose owner information is used to match the user launching mongod. Defaults to ${DATABASE_FOLDER}.
defineEnvVar PERMISSIONS_FOLDER MANDATORY "The folder whose owner information is used to match the user launching mongod" "${DATABASE_FOLDER}"
# env: CONFIG_FILE: The mongod.conf file.
defineEnvVar CONFIG_FILE MANDATORY "The mongod.conf file" "/etc/mongod.conf"
# env: DATABASE: The initial database.
defineEnvVar DATABASE MANDATORY "The initial database" "main"
# env: AUTHENTICATION_DATABASE: The authentication database. Defaults to "admin".
defineEnvVar AUTHENTICATION_DATABASE MANDATORY "The authentication database" "admin"
# env: AUTHENTICATION_MECHANISM: The authentication mechanism. Defaults to SCRAM-SHA-256.
defineEnvVar AUTHENTICATION_MECHANISM MANDATORY "The authentication mechanism" "SCRAM-SHA-256"
# env: ADMIN_USER_NAME: The MongoDB admin user. Defaults to "admin".
defineEnvVar ADMIN_USER_NAME MANDATORY "The MongoDB admin user" "admin"
# env: ADMIN_USER_PASSWORD: The password of the admin user.
defineEnvVar ADMIN_USER_PASSWORD MANDATORY "The password of the admin user"
# env: ENABLE_FREE_MONITORING: Whether to enable the free monitoring feature. Defaults to true.
defineEnvVar ENABLE_FREE_MONITORING MANDATORY "Whether to enable the free monitoring feature" true
# env: BACKUP_ROLE_NAME: The name of the MongoDB role used for backups. Defaults to "backupRestore".
defineEnvVar BACKUP_ROLE_NAME MANDATORY "The name of the MongoDB role used for backups" "backupRestore"
# env: BACKUP_ROLE_SPEC: The role specification of the backup user. Defaults to "[ \"${BACKUP_ROLE_NAME}\" ]".
defineEnvVar BACKUP_ROLE_SPEC MANDATORY "The role specification of the backup user" "[ \"${BACKUP_ROLE_NAME}\" ]"
# env: BACKUP_USER_NAME: The MongoDB backup user. Defaults to "backup".
defineEnvVar BACKUP_USER_NAME MANDATORY "The MongoDB backup user" "backup"
# env: BACKUP_USER_PASSWORD: The password of the backup user.
defineEnvVar BACKUP_USER_PASSWORD MANDATORY "The password of the backup user"
# env: START_TIMEOUT: How long to wait for mongod to start.
defineEnvVar START_TIMEOUT MANDATORY "How long to wait for mongod to start" 60
# env: START_CHECK_INTERVAL: How long till we check if mongod is running.
defineEnvVar START_CHECK_INTERVAL MANDATORY "How long till we check if mongod is running" 5
# env: LOCK_FILE: The file to lock the bootstrap process. Defaults to ${DATABASE_FOLDER}/.bootstrap-lock.
defineEnvVar LOCK_FILE MANDATORY "The file to lock the bootstrap process" "${DATABASE_FOLDER}/.bootstrap-lock"
# env: BOOTSTRAP_FILE: The file that indicates if the MongoDB instance has been already bootstrapped";
defineEnvVar BOOTSTRAP_FILE MANDATORY "The file that indicates if the MongoDB instance has been already bootstrapped" "${DATABASE_FOLDER}/.bootstrapped"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
