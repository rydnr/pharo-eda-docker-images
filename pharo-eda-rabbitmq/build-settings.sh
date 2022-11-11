# env: PARENT_IMAGE_TAG: The tag of the parent image. Defaults to latest.
defineEnvVar PARENT_IMAGE_TAG OPTIONAL "The tag of the parent image" "latest"
# env: SERVICE_GROUP: The service user. Defaults to rabbitmq.
defineEnvVar SERVICE_USER OPTIONAL "The service user" 'rabbitmq'
# env: SERVICE_GROUP: The service group. Defaults to rabbitmq.
defineEnvVar SERVICE_GROUP OPTIONAL "The service group" 'rabbitmq'
# env: SERVICE_USER_HOME: The home of the service user. Defaults to /home/${SERVICE_USER}.
defineEnvVar SERVICE_USER_HOME OPTIONAL "The home of the service user" '/home/${SERVICE_USER}'
# env: SERVICE_USER_PASSWORD: The password of the service user. Defaults to ${RANDOM_PASSWORD}.
defineEnvVar SERVICE_USER_PASSWORD OPTIONAL "The password of the service user" '${RANDOM_PASSWORD}'
# env: SERVICE_USER_SHELL: The shell of the service user. Defaults to /bin/bash.
defineEnvVar SERVICE_USER_SHELL OPTIONAL "The shell of the service user" '/bin/bash'
# env: CHANGESET_MONITORING_INTERVAL: The number of minutes to wait before checking if there're new pending scripts.
defineEnvVar CHANGESET_MONITORING_INTERVAL MANDATORY "The number of minutes to wait before checking if there're new pending scripts." 1
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
