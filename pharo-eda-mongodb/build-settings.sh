# env: PARENT_IMAGE_TAG: The tag of the parent image. Defaults to master.
defineEnvVar PARENT_IMAGE_TAG MANDATORY "The tag of the parent image" "master"
# env: MONGODB_MAJOR_VERSION: The MongoDB version. Defaults to 4.
defineEnvVar MONGODB_MAJOR_VERSION MANDATORY "The MongoDB version" "6"
# env: MONGODB_VERSION: The MongoDB version. Defaults to ${MONGODB_MAJOR_VERSION}.2.
defineEnvVar MONGODB_VERSION MANDATORY "The MongoDB version" '${MONGODB_MAJOR_VERSION}.0'
# env: AUTHENTICATION_MECHANISM: The authentication mechanism. Defaults to SCRAM-SHA-256.
defineEnvVar AUTHENTICATION_MECHANISM MANDATORY "The authentication mechanism" "SCRAM-SHA-256"
# env: ENABLE_FREE_MONITORING: Whether to enable free monitoring. Defaults to false.
defineEnvVar ENABLE_FREE_MONITORING MANDATORY "Whether to enable free monitoring" false
# env: SERVICE_USER: The service user. Defaults to mongodb.
defineEnvVar SERVICE_USER MANDATORY "The service user" 'mongodb'
# env: SERVICE_GROUP: The service group. Defaults to mongodb.
defineEnvVar SERVICE_GROUP MANDATORY "The service group" 'mongodb'
# env: SERVICE_USER_HOME: The home of the service user. Defaults to /home/${SERVICE_USER}.
defineEnvVar SERVICE_USER_HOME MANDATORY "The home of the service user" '/home/${SERVICE_USER}'
# env: SERVICE_USER_PASSWORD: The password of the service user. Defaults to ${RANDOM_PASSWORD}.
defineEnvVar SERVICE_USER_PASSWORD MANDATORY "The password of the service user" '${RANDOM_PASSWORD}'
# env: SERVICE_USER_SHELL: The shell of the service user. Defaults to /bin/bash.
defineEnvVar SERVICE_USER_SHELL MANDATORY "The shell of the service user" '/bin/bash'
# env: ADMIN_USER_NAME: The name of the admin user in MongoDB. Defaults to "admin".
defineEnvVar ADMIN_USER_NAME MANDATORY "The name of the admin user in MongoDB" "admin"
# env: BACKUP_USER_NAME: The name of the admin user in MongoDB. It's used for administrative tasks. Defaults to "backup".
defineEnvVar BACKUP_USER_NAME MANDATORY "The name of the admin user in MongoDB. It's used for administrative tasks" "backup"
# env: CHANGESET_MONITORING_INTERVAL: The number of minutes to wait before checking if there're new pending scripts.
defineEnvVar CHANGESET_MONITORING_INTERVAL MANDATORY "The number of minutes to wait before checking if there're new pending scripts." 5
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
