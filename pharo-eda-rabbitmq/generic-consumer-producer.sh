#!/usr/bin/env dry-wit
# (c) 2022-today Automated Computing Machinery, S.L.
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
# mod: pharo-eda-rabbitmq/generic-consumer-producer.sh
# api: public
# txt: Generic script for microservices in need of configuring a local RabbitMQ instance.

DW.import rabbitmq

# fun: configureLocalRabbitMQ
# api: public
# txt: Generic script for microservices in need of configuring a local RabbitMQ instance.
# txt: Returns 0/TRUE always, but can exit in case of error.
# use: configureLocalRabbitMQ;
function configureLocalRabbitMQ() {
  logInfo "Configuring local RabbitMQ for ${MICROSERVICE_NAME}"

  if ! add_users_if_necessary; then
    exitWithErrorCode CANNOT_ADD_THE_USERS
  fi

  if isNotEmpty "${COMMAND_EXCHANGE_USER_TAGS}" ||
    isNotEmpty "${EVENT_QUEUE_USER_TAGS}"; then

    if ! add_users_tags "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      exitWithErrorCode CANNOT_SET_THE_TAGS
    fi
  fi

  if ! set_users_permissions; then
    exitWithErrorCode CANNOT_SET_THE_PERMISSIONS
  fi

  if ! declare_exchanges_if_necessary; then
    exitWithErrorCode CANNOT_DECLARE_THE_EXCHANGES
  fi

  if ! declare_deadletter_exchanges_if_necessary; then
    exitWithErrorCode CANNOT_DECLARE_THE_DEADLETTER_EXCHANGES
  fi

  if ! declare_queues_if_necessary; then
    exitWithErrorCode CANNOT_DECLARE_THE_QUEUES
  fi

  if ! declare_deadletter_queues_if_necessary; then
    exitWithErrorCode CANNOT_DECLARE_THE_DEADLETTER_QUEUES
  fi

  if ! declare_audit_queues_if_necessary; then
    exitWithErrorCode CANNOT_DECLARE_THE_AUDIT_QUEUES
  fi

  if ! declare_deadletter_bindings_if_necessary; then
    exitWithErrorCode CANNOT_DECLARE_THE_DEADLETTER_BINDINGS
  fi

  if ! declare_audit_bindings_if_necessary; then
    exitWithErrorCode CANNOT_DECLARE_THE_AUDIT_BINDINGS
  fi

  if ! set_deadletter_exchanges_policies_if_necessary; then
    exitWithErrorCode CANNOT_SET_THE_DEADLETTER_EXCHANGES_POLICIES
  fi
}

# fun: add_users_if_necessary
# api: public
# txt: Adds the users, if necessary.
# txt: Returns 0/TRUE if the users get created successfully, or if they already existed; 1/FALSE otherwise.
# use: if add_users_if_necessary; then
# use:   echo "Users created successfully, or they already existed";
# use: fi
function add_users_if_necessary() {

  add_event_queue_user_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    add_event_exchange_user_if_necessary
    _rescode=$?
  fi

  if isTrue ${_rescode}; then
    add_command_queue_user_if_necessary
    _rescode=$?
  fi

  if isTrue ${_rescode}; then
    add_command_exchange_user_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: add_event_queue_user_if_necessary
# api: public
# txt: Adds the event queue user, if necessary.
# txt: Returns 0/TRUE if the user gets created successfully, or if it already existed; 1/FALSE otherwise.
# use: if add_event_queue_user_if_necessary; then
# use:   echo "User created successfully, or it already existed";
# use: fi
function add_event_queue_user_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_QUEUE_USER_NAME}" &&
    ! userAlreadyExists "${EVENT_QUEUE_USER_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Creating user for consuming events from ${EVENT_QUEUE_NAME}: ${EVENT_QUEUE_USER_NAME}"
    if addUser "${EVENT_QUEUE_USER_NAME}" "${EVENT_QUEUE_USER_PASSWORD}" "${RABBITMQ_NODENAME}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: add_event_exchange_user_if_necessary
# api: public
# txt: Adds the event exchange user, if necessary.
# txt: Returns 0/TRUE if the user gets created successfully, or if it already existed; 1/FALSE otherwise.
# use: if add_event_exchange_user_if_necessary; then
# use:   echo "User created successfully, or it already existed";
# use: fi
function add_event_exchange_user_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_EXCHANGE_USER_NAME}" &&
    ! userAlreadyExists "${EVENT_EXCHANGE_USER_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Creating user for publishing events in ${EVENT_EXCHANGE_NAME}: ${EVENT_EXCHANGE_USER_NAME}"
    if addUser "${EVENT_EXCHANGE_USER_NAME}" "${EVENT_EXCHANGE_USER_PASSWORD}" "${RABBITMQ_NODENAME}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: add_command_queue_user_if_necessary
# api: public
# txt: Adds the command queue user, if necessary.
# txt: Returns 0/TRUE if the user gets created successfully, or if it already existed; 1/FALSE otherwise.
# use: if add_command_queue_user_if_necessary; then
# use:   echo "User created successfully, or it already existed";
# use: fi
function add_command_queue_user_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_QUEUE_USER_NAME}" &&
    ! userAlreadyExists "${COMMAND_QUEUE_USER_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Creating user for consuming commands from ${COMMAND_QUEUE_NAME}: ${COMMAND_QUEUE_USER_NAME}"
    if addUser "${COMMAND_QUEUE_USER_NAME}" "${COMMAND_QUEUE_USER_PASSWORD}" "${RABBITMQ_NODENAME}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: add_command_exchange_user_if_necessary
# api: public
# txt: Adds the command exchange user, if necessary.
# txt: Returns 0/TRUE if the user gets created successfully, or if it already existed; 1/FALSE otherwise.
# use: if add_command_exchange_user_if_necessary; then
# use:   echo "User created successfully, or it already existed";
# use: fi
function add_command_exchange_user_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_EXCHANGE_USER_NAME}" &&
    ! userAlreadyExists "${COMMAND_EXCHANGE_USER_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Creating user for publishing commands in ${COMMAND_EXCHANGE_NAME}: ${COMMAND_EXCHANGE_USER_NAME}"
    if addUser "${COMMAND_EXCHANGE_USER_NAME}" "${COMMAND_EXCHANGE_USER_PASSWORD}" "${RABBITMQ_NODENAME}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi
}

# fun: add_users_tags acessUser accessPassword
# api: public
# txt: Adds some tags for the users.
# opt: accessUser: The user used to connect to the RabbitMQ instance. Optional.
# opt: accessPassword: The credentials of accessUser. Optional.
# txt: Returns 0/TRUE if the tags are added successfully; 1/FALSE otherwise.
# use: if add_users_tags admin 'secret'; then
# use:   echo "Tags added successfully";
# use: fi
function add_users_tags() {
  local _accessUser="${1}"
  local _accessPassword="${2}"

  add_event_queue_user_tags_if_necessary "${_accessUser}" "${_accessPassword}"
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    add_event_exchange_user_tags_if_necessary "${_accessUser}" "${_accessPassword}"
    _rescode=$?
  fi

  if isTrue ${_rescode}; then
    add_command_queue_user_tags_if_necessary "${_accessUser}" "${_accessPassword}"
    _rescode=$?
  fi
  if isTrue ${_rescode}; then
    add_command_exchange_user_tags_if_necessary "${_accessUser}" "${_accessPassword}"
    _rescode=$?
  fi
}

# fun: add_event_queue_user_tags_if_necessary acessUser accessPassword
# api: public
# txt: Adds some tags for the event queue user.
# opt: accessUser: The user used to connect to the RabbitMQ instance. Optional.
# opt: accessPassword: The credentials of accessUser. Optional.
# txt: Returns 0/TRUE if the tags are added successfully; 1/FALSE otherwise.
# use: if add_event_queue_user_tags_if_necessary admin 'secret'; then
# use:   echo "Tags added successfully";
# use: fi
function add_event_queue_user_tags_if_necessary() {
  local _accessUser="${1}"
  local _accessPassword="${2}"

  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_QUEUE_USER_NAME}"; then
    local _oldIFS="${IFS}"
    local _tag
    IFS="${DWIFS}"
    for _tag in ${EVENT_QUEUE_USER_TAGS}; do
      IFS="${_oldIFS}"
      logDebug -n "Adding tag ${_tag} to ${EVENT_QUEUE_USER_NAME}"
      if addTagToUser "${EVENT_QUEUE_USER_NAME}" "${_tag}" "${RABBITMQ_NODENAME}" "${_accessUser}" "${_accessPassword}"; then
        logDebugResult SUCCESS "done"
      else
        logDebugResult FAILURE "failed"
        logInfo "${ERROR}"
      fi
    done
    IFS="${_oldIFS}"
  fi

  return ${_rescode}
}

# fun: add_event_exchange_user_tags_if_necessary acessUser accessPassword
# api: public
# txt: Adds some tags for the event exchange user.
# opt: accessUser: The user used to connect to the RabbitMQ instance. Optional.
# opt: accessPassword: The credentials of accessUser. Optional.
# txt: Returns 0/TRUE if the tags are added successfully; 1/FALSE otherwise.
# use: if add_event_exchange_user_tags_if_necessary admin 'secret'; then
# use:   echo "Tags added successfully";
# use: fi
function add_event_exchange_user_tags_if_necessary() {
  local _accessUser="${1}"
  local _accessPassword="${2}"

  local -i _rescode=${TRUE}

  if isNotEmpty ${EVENT_EXCHANGE_USER_NAME}; then
    local _oldIFS="${IFS}"
    local _tag
    IFS="${DWIFS}"
    for _tag in ${EVENT_EXCHANGE_USER_TAGS}; do
      IFS="${_oldIFS}"
      if addTagToUser "${EVENT_EXCHANGE_USER_NAME}" "${_tag}" "${RABBITMQ_NODENAME}" "${_accessUser}" "${_accessPassword}"; then
        logDebugResult SUCCESS "done"
      else
        logDebugResult FAILURE "failed"
        logInfo "${ERROR}"
      fi
    done
    IFS="${_oldIFS}"
  fi

  return ${_rescode}
}

# fun: add_command_queue_user_tags_if_necessary acessUser accessPassword
# api: public
# txt: Adds some tags for the command queue user.
# opt: accessUser: The user used to connect to the RabbitMQ instance. Optional.
# opt: accessPassword: The credentials of accessUser. Optional.
# txt: Returns 0/TRUE if the tags are added successfully; 1/FALSE otherwise.
# use: if add_command_queue_user_tags_if_necessary admin 'secret'; then
# use:   echo "Tags added successfully";
# use: fi
function add_command_queue_user_tags_if_necessary() {
  local _accessUser="${1}"
  local _accessPassword="${2}"

  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_QUEUE_USER_NAME}"; then
    local _oldIFS="${IFS}"
    local _tag
    IFS="${DWIFS}"
    for _tag in ${COMMAND_QUEUE_USER_TAGS}; do
      IFS="${_oldIFS}"
      if addTagToUser "${COMMAND_QUEUE_USER_NAME}" "${_tag}" "${RABBITMQ_NODENAME}" "${_accessUser}" "${_accessPassword}"; then
        logDebugResult SUCCESS "done"
      else
        logDebugResult FAILURE "failed"
        logInfo "${ERROR}"
      fi
    done
    IFS="${_oldIFS}"
  fi

  return ${_rescode}
}

# fun: add_command_exchange_user_tags_if_necessary acessUser accessPassword
# api: public
# txt: Adds some tags for the command exchange user.
# opt: accessUser: The user used to connect to the RabbitMQ instance. Optional.
# opt: accessPassword: The credentials of accessUser. Optional.
# txt: Returns 0/TRUE if the tags are added successfully; 1/FALSE otherwise.
# use: if add_command_exchange_user_tags_if_necessary admin 'secret'; then
# use:   echo "Tags added successfully";
# use: fi
function add_command_exchange_user_tags_if_necessary() {
  local _accessUser="${1}"
  local _accessPassword="${2}"

  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_EXCHANGE_USER_NAME}"; then
    local _oldIFS="${IFS}"
    local _tag
    IFS="${DWIFS}"
    for _tag in ${COMMAND_EXCHANGE_USER_TAGS}; do
      IFS="${_oldIFS}"
      if addTagToUser "${COMMAND_EXCHANGE_USER_NAME}" "${_tag}" "${RABBITMQ_NODENAME}" "${_accessUser}" "${_accessPassword}"; then
        logDebugResult SUCCESS "done"
      else
        logDebugResult FAILURE "failed"
        logInfo "${ERROR}"
      fi
    done
    IFS="${_oldIFS}"
  fi

  return ${_rescode}
}

# fun: set_users_permissions
# api: public
# txt: Sets the users permissions.
# txt: Returns 0/TRUE if the permissions are set successfully; 1/FALSE otherwise.
# use: if set_users_permissions; then
# use:   echo "Users permissions set successfully";
# use: fi
function set_users_permissions() {

  # TODO: FIX THE VIRTUALHOST
  local _vhost="/"

  set_event_queue_user_permissions_if_necessary "${_vhost}"
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    set_event_exchange_user_permissions_if_necessary "${_vhost}"
    _rescode=$?
  fi

  if isTrue ${_rescode}; then
    set_command_queue_user_permissions_if_necessary "${_vhost}"
    _rescode=$?
  fi

  if isTrue ${_rescode}; then
    set_command_exchange_user_permissions_if_necessary "${_vhost}"
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: set_event_queue_user_permissions_if_necessary vhost
# api: public
# txt: Sets the event queue user permissions, if necessary.
# opt: vhost: The virtual host.
# txt: Returns 0/TRUE if the permissions were unneeded or are set successfully; 1/FALSE otherwise.
# use: if set_event_queue_user_permissions_if_necessary /; then
# use:   echo "User permissions set successfully";
# use: fi
function set_event_queue_user_permissions_if_necessary() {
  local _vhost="${1}"
  checkNotEmpty vhost "${_vhost}" 1

  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_QUEUE_USER_NAME}"; then
    logDebug -n "Setting permissions for ${EVENT_QUEUE_USER_NAME} in ${_vhost}"
    if setPermissions "${_vhost}" "${EVENT_QUEUE_USER_NAME}" "${EVENT_QUEUE_USER_CONFIGURE_PERMISSIONS}" "${EVENT_QUEUE_USER_WRITE_PERMISSIONS}" "${EVENT_QUEUE_USER_READ_PERMISSIONS}" "${RABBITMQ_NODENAME}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: set_event_queue_user_permissions_if_necessary vhost
# api: public
# txt: Sets the event queue user permissions, if necessary.
# opt: vhost: The virtual host.
# txt: Returns 0/TRUE if the permissions were unneeded or are set successfully; 1/FALSE otherwise.
# use: if set_event_exchange_user_permissions_if_necessary /; then
# use:   echo "User permissions set successfully";
# use: fi
function set_event_exchange_user_permissions_if_necessary() {
  local _vhost="${1}"
  checkNotEmpty vhost "${_vhost}" 1

  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_EXCHANGE_USER_NAME}"; then
    logDebug -n "Setting permissions for ${EVENT_EXCHANGE_USER_NAME} in ${_vhost}"
    if setPermissions "${_vhost}" "${EVENT_EXCHANGE_USER_NAME}" "${EVENT_EXCHANGE_USER_CONFIGURE_PERMISSIONS}" "${EVENT_EXCHANGE_USER_WRITE_PERMISSIONS}" "${EVENT_EXCHANGE_USER_READ_PERMISSIONS}" "${RABBITMQ_NODENAME}"; then
      logDebugResult SUCCESS "done;"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: set_command_queue_user_permissions_if_necessary vhost
# api: public
# txt: Sets the commandevent queue user permissions, if necessary.
# opt: vhost: The virtual host.
# txt: Returns 0/TRUE if the permissions were unneeded or are set successfully; 1/FALSE otherwise.
# use: if set_command_queue_user_permissions_if_necessary /; then
# use:   echo "User permissions set successfully";
# use: fi
function set_command_queue_user_permissions_if_necessary() {
  local _vhost="${1}"
  checkNotEmpty vhost "${_vhost}" 1

  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_QUEUE_USER_NAME}"; then
    logDebug -n "Setting permissions for ${COMMAND_QUEUE_USER_NAME} in ${_vhost}"
    if setPermissions "${_vhost}" "${COMMAND_QUEUE_USER_NAME}" "${COMMAND_QUEUE_USER_CONFIGURE_PERMISSIONS}" "${COMMAND_QUEUE_USER_WRITE_PERMISSIONS}" "${COMMAND_QUEUE_USER_READ_PERMISSIONS}" "${RABBITMQ_NODENAME}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: set_command_exchange_user_permissions_if_necessary vhost
# api: public
# txt: Sets the command exchange user permissions, if necessary.
# opt: vhost: The virtual host.
# txt: Returns 0/TRUE if the permissions were unneeded or are set successfully; 1/FALSE otherwise.
# use: if set_command_exchange_user_permissions_if_necessary /; then
# use:   echo "User permissions set successfully";
# use: fi
function set_command_exchange_user_permissions_if_necessary() {
  local _vhost="${1}"
  checkNotEmpty vhost "${_vhost}" 1

  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_EXCHANGE_USER_NAME}"; then
    logDebug -n "Setting permissions for ${COMMAND_EXCHANGE_USER_NAME} in ${_vhost}"
    if setPermissions "${_vhost}" "${COMMAND_EXCHANGE_USER_NAME}" "${COMMAND_EXCHANGE_USER_CONFIGURE_PERMISSIONS}" "${COMMAND_EXCHANGE_USER_WRITE_PERMISSIONS}" "${COMMAND_EXCHANGE_USER_READ_PERMISSIONS}" "${RABBITMQ_NODENAME}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_exchanges_if_necessary
# api: public
# txt: Declares the exchanges, if necessary.
# txt: Returns 0/TRUE if the exchange get created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_exchanges_if_necessary; then
# use:   echo "Exchanges created successfully";
# use: fi
function declare_exchanges_if_necessary() {

  declare_event_exchange_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    declare_command_exchange_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: declare_event_exchange_if_necessary
# api: public
# txt: Declares the event exchange, if necessary.
# txt: Returns 0/TRUE if the event exchange gets created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_event_exchange_if_necessary; then
# use:   echo "Exchange created successfully";
# use: fi
function declare_event_exchange_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_EXCHANGE_NAME}" &&
    ! exchangeAlreadyExists "${EVENT_EXCHANGE_NAME}" "${EVENT_EXCHANGE_TYPE}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring exchange ${EVENT_EXCHANGE_NAME}"
    if declareExchange "${EVENT_EXCHANGE_NAME}" "${EVENT_EXCHANGE_TYPE}" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}" "${EVENT_EXCHANGE_DURABLE}" "${EVENT_EXCHANGE_INTERNAL}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_command_exchange_if_necessary
# api: public
# txt: Declares the command exchange, if necessary.
# txt: Returns 0/TRUE if the command exchange gets created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_command_exchange_if_necessary; then
# use:   echo "Exchange created successfully";
# use: fi
function declare_command_exchange_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_EXCHANGE_NAME}" &&
    ! exchangeAlreadyExists "${COMMAND_EXCHANGE_NAME}" "${COMMAND_EXCHANGE_TYPE}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring exchange ${COMMAND_EXCHANGE_NAME}"
    if declareExchange "${COMMAND_EXCHANGE_NAME}" "${COMMAND_EXCHANGE_TYPE}" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}" "${COMMAND_EXCHANGE_DURABLE}" "${COMMAND_EXCHANGE_INTERNAL}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_deadletter_exchanges_if_necessary
# api: public
# txt: Declares the dead-letter exchanges, if necessary.
# txt: Returns 0/TRUE if the dead-letter exchanges are declared successfully, or they already existed; 1/FALSE otherwise.
# use: if declare_deadletter_exchanges_if_necessary; then
# use:   echo "Dead-letter exchanges created successfully, or already existed";
# use: fi
function declare_deadletter_exchanges_if_necessary() {
  declare_event_deadletter_exchange_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    declare_command_deadletter_exchange_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: declare_event_deadletter_exchange_if_necessary
# api: public
# txt: Declares the event dead-letter exchange, if necessary.
# txt: Returns 0/TRUE if the dead-letter exchange is declared successfully, or it already existed; 1/FALSE otherwise.
# use: if declare_event_deadletter_exchange_if_necessary; then
# use:   echo "Event dead-letter exchange created successfully, or already existed";
# use: fi
function declare_event_deadletter_exchange_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_DLX_NAME}" &&
    ! exchangeAlreadyExists "${EVENT_DLX_NAME}" "${EVENT_DLX_TYPE}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring exchange ${EVENT_DLX_NAME}"
    if declareExchange "${EVENT_DLX_NAME}" "${EVENT_DLX_TYPE}" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_command_deadletter_exchange_if_necessary
# api: public
# txt: Declares the command dead-letter exchange, if necessary.
# txt: Returns 0/TRUE if the dead-letter exchange is declared successfully, or it already existed; 1/FALSE otherwise.
# use: if declare_command_deadletter_exchange_if_necessary; then
# use:   echo "Command dead-letter exchange created successfully, or already existed";
# use: fi
function declare_command_deadletter_exchange_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_DLX_NAME}" &&
    ! exchangeAlreadyExists "${COMMAND_DLX_NAME}" "${COMMAND_DLX_TYPE}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring exchange ${COMMAND_DLX_NAME}"
    if declareExchange "${COMMAND_DLX_NAME}" "${COMMAND_DLX_TYPE}" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_queues_if_necessary
# api: public
# txt: Declares the queues, if necessary.
# txt: Returns 0/TRUE if the queues are declared successfully or already existed; 1/FALSE otherwise.
# use: if declare_queues_if_necessary; then
# use:   echo "Queues created successfully, or already existed";
# use: fi
function declare_queues_if_necessary() {

  declare_event_queue_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    declare_command_queue_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: declare_event_queue_if_necessary
# api: public
# txt: Declares the event queue, if necessary.
# txt: Returns 0/TRUE if the event queue is declared successfully or already existed; 1/FALSE otherwise.
# use: if declare_event_queue_if_necessary; then
# use:   echo "Queue created successfully, or already existed";
# use: fi
function declare_event_queue_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_QUEUE_NAME}" &&
    ! queueAlreadyExists "${EVENT_QUEUE_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring queue ${EVENT_QUEUE_NAME}"
    if declareQueue "${EVENT_QUEUE_NAME}" ${EVENT_QUEUE_DURABLE} "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_command_queue_if_necessary
# api: public
# txt: Declares the command queue, if necessary.
# txt: Returns 0/TRUE if the command queue is declared successfully or already existed; 1/FALSE otherwise.
# use: if declare_command_queue_if_necessary; then
# use:   echo "Command created successfully, or already existed";
# use: fi
function declare_command_queue_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_QUEUE_NAME}" &&
    ! queueAlreadyExists "${COMMAND_QUEUE_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring queue ${COMMAND_QUEUE_NAME}"
    if declareQueue "${COMMAND_QUEUE_NAME}" ${COMMAND_QUEUE_DURABLE} "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_deadletter_queues_if_necessary
# api: public
# txt: Declares the dead-letter queues, if necessary.
# txt: Returns 0/TRUE if the dead-letter queues are declared successfully or they already existed; 1/FALSE otherwise..
# use: if declare_deadletter_queues_if_necessary; then
# use:   echo "Dead-letter queues created successfully, or already existed";
# use: fi
function declare_deadletter_queues_if_necessary() {

  declare_event_deadletter_queue_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    declare_command_deadletter_queue_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: declare_event_deadletter_queue_if_necessary
# api: public
# txt: Declares the event dead-letter queue, if necessary.
# txt: Returns 0/TRUE if the event dead-letter queue is declared successfully or it already existed; 1/FALSE otherwise..
# use: if declare_event_deadletter_queue_if_necessary; then
# use:   echo "Event dead-letter queue created successfully, or already existed";
# use: fi
function declare_event_deadletter_queue_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_DLQ_NAME}" &&
    ! queueAlreadyExists "${EVENT_DLQ_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring queue ${EVENT_DLQ_NAME}"
    if declareQueue "${EVENT_DLQ_NAME}" ${EVENT_DLQ_DURABLE} "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_command_deadletter_queue_if_necessary
# api: public
# txt: Declares the command dead-letter queue, if necessary.
# txt: Returns 0/TRUE if the command dead-letter queue is declared successfully or it already existed; 1/FALSE otherwise..
# use: if declare_command_deadletter_queue_if_necessary; then
# use:   echo "Command dead-letter queue created successfully, or already existed";
# use: fi
function declare_command_deadletter_queue_if_necessary() {
  local -i _rescode=${TRUE}

  if isTrue ${_rescode} &&
    isNotEmpty "${COMMAND_DLQ_NAME}" &&
    ! queueAlreadyExists "${COMMAND_DLQ_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring queue ${COMMAND_DLQ_NAME}"
    if declareQueue "${COMMAND_DLQ_NAME}" ${COMMAND_DLQ_DURABLE} "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_audit_queues_if_necessary
# api: public
# txt: Declares the audit queues, if necessary.
# txt: Returns 0/TRUE if the audit queues are declared successfully, or already existed; 1/FALSE otherwise.
# use: if declare_audit_queues_if_necessary; then
# use:   echo "Audit queues created successfully, or already existed";
# use: fi
function declare_audit_queues_if_necessary() {

  declare_event_audit_queue_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    declare_command_audit_queue_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: declare_event_audit_queue_if_necessary
# api: public
# txt: Declares the event audit queue, if necessary.
# txt: Returns 0/TRUE if the event audit queue are declared successfully, or already existed; 1/FALSE otherwise.
# use: if declare_event_audit_queue_if_necessary; then
# use:   echo "Event audit queue created successfully, or already existed";
# use: fi
function declare_event_audit_queue_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_AUDIT_QUEUE_NAME}" &&
    ! queueAlreadyExists "${EVENT_AUDIT_QUEUE_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring queue ${EVENT_AUDIT_QUEUE_NAME}"
    if declareQueue "${EVENT_AUDIT_QUEUE_NAME}" ${EVENT_AUDIT_QUEUE_DURABLE} "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_command_audit_queue_if_necessary
# api: public
# txt: Declares the command audit queue, if necessary.
# txt: Returns 0/TRUE if the command audit queue are declared successfully, or already existed; 1/FALSE otherwise.
# use: if declare_command_audit_queue_if_necessary; then
# use:   echo "Event audit queue created successfully, or already existed";
# use: fi
function declare_command_audit_queue_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_AUDIT_QUEUE_NAME}" &&
    ! queueAlreadyExists "${COMMAND_AUDIT_QUEUE_NAME}" "${RABBITMQ_NODENAME}"; then
    logDebug -n "Declaring queue ${COMMAND_AUDIT_QUEUE_NAME}"
    if declareQueue "${COMMAND_AUDIT_QUEUE_NAME}" ${COMMAND_AUDIT_QUEUE_DURABLE} "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_deadletter_bindings_if_necessary
# api: public
# txt: Declares the dead-letter bindings, if necessary.
# txt: Returns 0/TRUE if the dead-letter bindings get created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_deadletter_bindings_if_necessary; then
# use:   echo "Dead-letter bindings declared successfully, or already existed";
# use: fi
function declare_deadletter_bindings_if_necessary() {

  declare_event_deadletter_bindings_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    declare_command_deadletter_bindings_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: declare_event_deadletter_bindings_if_necessary
# api: public
# txt: Declares the event dead-letter bindings, if necessary.
# txt: Returns 0/TRUE if the event dead-letter bindings get created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_event_deadletter_bindings_if_necessary; then
# use:   echo "Event dead-letter bindings declared successfully, or already existed";
# use: fi
function declare_event_deadletter_bindings_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_DLX_NAME}" &&
    ! bindingAlreadyExists "${EVENT_DLX_NAME}" queue "${EVENT_DLQ_NAME}" "#" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
    logDebug -n "Declaring binding ${EVENT_DLX_NAME} -> ${EVENT_DLQ_NAME}"
    if declareBinding "${EVENT_DLX_NAME}" queue "${EVENT_DLQ_NAME}" "#" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_command_deadletter_bindings_if_necessary
# api: public
# txt: Declares the command dead-letter bindings, if necessary.
# txt: Returns 0/TRUE if the command dead-letter bindings get created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_command_deadletter_bindings_if_necessary; then
# use:   echo "Command dead-letter bindings declared successfully, or already existed";
# use: fi
function declare_command_deadletter_bindings_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_DLX_NAME}" &&
    ! bindingAlreadyExists "${COMMAND_DLX_NAME}" queue "${COMMAND_DLQ_NAME}" "#" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
    logDebug -n "Declaring binding ${COMMAND_DLX_NAME} -> ${COMMAND_DLQ_NAME}"
    if declareBinding "${COMMAND_DLX_NAME}" queue "${COMMAND_DLQ_NAME}" "#" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_audit_bindings_if_necessary
# api: public
# txt: Declares the audit bindings, if necessary.
# txt: Returns 0/TRUE if the audit bindings get created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_audit_bindings_if_necessary; then
# use:   echo "Audit bindings declared successfully, or already existed";
# use: fi
function declare_audit_bindings_if_necessary() {

  declare_event_audit_bindings_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    declare_command_audit_bindings_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: declare_event_audit_bindings_if_necessary
# api: public
# txt: Declares the event audit bindings, if necessary.
# txt: Returns 0/TRUE if the event audit bindings get created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_event_audit_bindings_if_necessary; then
# use:   echo "Event audit bindings declared successfully, or already existed";
# use: fi
function declare_event_audit_bindings_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_EXCHANGE_NAME}" &&
    ! bindingAlreadyExists "${EVENT_EXCHANGE_NAME}" queue "${EVENT_AUDIT_QUEUE_NAME}" "#" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
    logDebug -n "Declaring binding ${EVENT_EXCHANGE_NAME} -> ${EVENT_AUDIT_QUEUE_NAME}"
    if declareBinding "${EVENT_EXCHANGE_NAME}" queue "${EVENT_AUDIT_QUEUE_NAME}" "#" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_command_audit_bindings_if_necessary
# api: public
# txt: Declares the command audit bindings, if necessary.
# txt: Returns 0/TRUE if the command audit bindings get created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_command_audit_bindings_if_necessary; then
# use:   echo "Command audit bindings declared successfully, or already existed";
# use: fi
function declare_command_audit_bindings_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_EXCHANGE_NAME}" &&
    ! bindingAlreadyExists "${COMMAND_EXCHANGE_NAME}" queue "${COMMAND_AUDIT_QUEUE_NAME}" "#" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
    logDebug -n "Declaring binding ${COMMAND_EXCHANGE_NAME} -> ${COMMAND_AUDIT_QUEUE_NAME}"
    if declareBinding "${COMMAND_EXCHANGE_NAME}" queue "${COMMAND_AUDIT_QUEUE_NAME}" "#" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: set_deadletter_exchanges_policies_if_necessary
# api: public
# txt: Sets the policies, if necessary.
# txt: Returns 0/TRUE if the policies get created successfully, or they already existed; 1/FALSE otherwise.
# use: if set_deadletter_exchanges_policies_if_necessary; then
# use:   echo "Policies set successfully, or they already existed";
# use: fi
function set_deadletter_exchanges_policies_if_necessary() {

  set_event_deadletter_exchange_policies_if_necessary
  local -i _rescode=$?

  if isTrue ${_rescode}; then
    set_command_deadletter_exchange_policies_if_necessary
    _rescode=$?
  fi

  return ${_rescode}
}

# fun: set_event_deadletter_exchange_policies_if_necessary
# api: public
# txt: Sets the policies for the event dead-letter exchange, if necessary.
# txt: Returns 0/TRUE if the policies get created successfully, or they already existed; 1/FALSE otherwise.
# use: if set_event_deadletter_exchange_policies_if_necessary; then
# use:   echo "Policies set successfully, or they already existed";
# use: fi
function set_event_deadletter_exchange_policies_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${EVENT_DLX_NAME}" &&
    ! policyAlreadyExists "${EVENT_DLX_NAME}" "^${EVENT_QUEUE_NAME}$" "{\"dead-letter-exchange\":\"${EVENT_DLX_NAME}\"}" queues "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
    logDebug -n "Setting ${EVENT_DLX_NAME}'s policy"
    if setPolicy "${EVENT_DLX_NAME}" "^${EVENT_QUEUE_NAME}$" "{\"dead-letter-exchange\":\"${EVENT_DLX_NAME}\"}" queues "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: set_command_deadletter_exchange_policies_if_necessary
# api: public
# txt: Sets the policies for the command dead-letter exchange, if necessary.
# txt: Returns 0/TRUE if the policies get created successfully, or they already existed; 1/FALSE otherwise.
# use: if set_command_deadletter_exchange_policies_if_necessary; then
# use:   echo "Policies set successfully, or they already existed";
# use: fi
function set_command_deadletter_exchange_policies_if_necessary() {
  local -i _rescode=${TRUE}

  if isNotEmpty "${COMMAND_DLX_NAME}" &&
    ! policyAlreadyExists "${COMMAND_DLX_NAME}" "^${COMMAND_QUEUE_NAME}$" "{\"dead-letter-exchange\":\"${COMMAND_DLX_NAME}\"}" queues "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
    logDebug -n "Setting policy for ${COMMAND_DLX_NAME}"
    if setPolicy "${COMMAND_DLX_NAME}" "^${COMMAND_QUEUE_NAME}$" "{\"dead-letter-exchange\":\"${COMMAND_DLX_NAME}\"}" queues "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"; then
      logDebugResult SUCCESS "done"
    else
      _rescode=${FALSE}
      logDebugResult FAILURE "failed"
      logInfo "${ERROR}"
    fi
  fi

  return ${_rescode}
}

# fun: declare_queue_bindings_if_necessary bindings from to
# api: public
# txt: Declares the bindings, if necessary.
# opt: bindings: The bindings.
# opt: from: The exchange.
# opt: to: The queue.
# txt: Returns 0/TRUE if the bindings get created successfully, or already existed; 1/FALSE otherwise.
# use: if declare_bindings_if_necessary '#' 'events-from-a' 'events-to-b'; then
# use:   echo "Bindings declared successfully, or already existed";
# use: fi
function declare_bindings_if_necessary() {
  local _bindings="${1}"
  checkNotEmpty bindings "${_bindings}" 1
  local _from="${2}"
  checkNotEmpty from "${_from}" 2
  local _to="${3}"
  checkNotEmpty to "${_to}" 3

  local -i _rescode=${TRUE}

  local _oldIFS="${IFS}"
  local _binding

  IFS="${DWIFS}"
  for _binding in ${_bindings}; do
    IFS="${_oldIFS}"
    declareBinding "${_from}" queue "${_to}" "${_binding}" "${RABBITMQ_NODENAME}" "${ADMIN_USER_NAME}" "${ADMIN_USER_PASSWORD}"
    _rescode=$?
    if isFalse ${_rescode}; then
      break
    fi
  done
  IFS="${_oldIFS}"

  return ${_rescode}
}

# Script metadata

setScriptDescription "Generic script for microservices in need of configuring a local RabbitMQ instance."

addError CANNOT_ADD_THE_USERS "Cannot add the user(s)"
addError CANNOT_SET_THE_TAGS "Cannot set the user tags"
addError CANNOT_SET_THE_PERMISSIONS "Cannot set the user permissions"
addError CANNOT_DECLARE_THE_EXCHANGES "Cannot declare the exchanges"
addError CANNOT_DECLARE_THE_DEADLETTER_EXCHANGES "Cannot declare the dead-letter exchanges"
addError CANNOT_DECLARE_THE_QUEUES "Cannot declare the queues"
addError CANNOT_DECLARE_THE_DEADLETTER_QUEUES "Cannot declare the dead-letter queues"
addError CANNOT_DECLARE_THE_AUDIT_QUEUES "Cannot declare the audit queues"
addError CANNOT_DECLARE_THE_BINDINGS "Cannot declare the bindings"
addError CANNOT_DECLARE_THE_DEADLETTER_BINDINGS "Cannot declare the dead-letter bindings"
addError CANNOT_DECLARE_THE_AUDIT_BINDINGS "Cannot declare the audit bindings"
addError CANNOT_SET_THE_DEADLETTER_EXCHANGES_POLICIES "Cannot set the policies for the dead-letter exchanges"

# env: MICROSERVICE_NAME: The name of the microservice.
defineEnvVar MICROSERVICE_NAME MANDATORY "The name of the microservice"

# env: ADMIN_USER_NAME: The name of the admin user.
defineEnvVar ADMIN_USER_NAME MANDATORY "The name of the admin user" admin
# env: ADMIN_USER_PASSWORD: The password of the admin user.
defineEnvVar ADMIN_USER_PASSWORD MANDATORY "The password of the admin user"

# env: EVENT_QUEUE_USER_NAME: The login of the user used to read events from. Optional.
defineEnvVar EVENT_QUEUE_USER_NAME OPTIONAL "The login of the user used to read events from"
# env: EVENT_QUEUE_USER_PASSWORD: The password of the user used to read events from. Optional.
defineEnvVar EVENT_QUEUE_USER_PASSWORD OPTIONAL "The password of the user used to read events from"
# env: EVENT_QUEUE_USER_TAGS: The tags of the user used to read events from. Optional.
defineEnvVar EVENT_QUEUE_USER_TAGS OPTIONAL "The tags of the user used to read events from" ""
# env: EVENT_QUEUE_USER_CONFIGURE_PERMISSIONS: The configure permissions for the user used to read events from. Optional.
defineEnvVar EVENT_QUEUE_USER_CONFIGURE_PERMISSIONS OPTIONAL "The configure permissions for the user used to read events from" ".*"
# env: EVENT_QUEUE_USER_WRITE_PERMISSIONS: The write permissions for the user used to read events from. Optional.
defineEnvVar EVENT_QUEUE_USER_WRITE_PERMISSIONS OPTIONAL "The write permissions for the user used to read events from" ".*"
# env: EVENT_QUEUE_USER_READ_PERMISSIONS: The read permissions for the user used to read events from. Optional.
defineEnvVar EVENT_QUEUE_USER_READ_PERMISSIONS OPTIONAL "The read permissions for the user used to read events from" ".*"

# env: EVENT_QUEUE_NAME: The name of the events queue. Optional.
defineEnvVar EVENT_QUEUE_NAME OPTIONAL "The name of the queue Backoffice reads from"
# env: EVENT_QUEUE_DURABLE: Whether the Backoffice queue should be durable or not. Optional.
defineEnvVar EVENT_QUEUE_DURABLE OPTIONAL "Whether the event queue should be durable or not" true
# env: EVENT_DLQ_NAME: The name of the Backoffice dead-letter queue. Optional.
defineEnvVar EVENT_DLQ_NAME OPTIONAL "The name of the event dead-letter queue"
# env: EVENT_DLQ_DURABLE: Whether the Backoffice dead-letter queue should be durable or not. Optional.
defineEnvVar EVENT_DLQ_DURABLE OPTIONAL "Whether the Backoffice dead-letter queue should be durable or not" true

# env: EVENT_DLX_NAME: The name of the dead-letter exchange for unprocessed events. Optional.
defineEnvVar EVENT_DLX_NAME OPTIONAL "The name of the dead-letter exchange for unprocessed events"
# env: EVENT_DLX_TYPE: The type of the dead-letter exchange for unprocessed events. Optional.
defineEnvVar EVENT_DLX_TYPE OPTIONAL "The type of the dead-letter exchange for unprocessed events" fanout

# env: EVENT_EXCHANGE_USER_NAME: The login to connect to the event exchange. Optional.
defineEnvVar EVENT_EXCHANGE_USER_NAME OPTIONAL "The login to connect to the event exchange"
# env: EVENT_EXCHANGE_USER_PASSWORD: The password of the user used to connect to the event exchange. Optional.
defineEnvVar EVENT_EXCHANGE_USER_PASSWORD OPTIONAL "The password of the user used to connect to the event exchange"
# env: EVENT_EXCHANGE_USER_TAGS: The tags of the user used to connect to the event exchange. Optional.
defineEnvVar EVENT_EXCHANGE_USER_TAGS OPTIONAL "The tags of the user used to connect to the event exchange" ""
# env: EVENT_EXCHANGE_USER_CONFIGURE_PERMISSIONS: The configure permissions for the user used to connect to the event exchange. Optional.
defineEnvVar EVENT_EXCHANGE_USER_CONFIGURE_PERMISSIONS OPTIONAL "The configure permissions for the user used to connect to the event exchange" ".*"
# env: EVENT_EXCHANGE_USER_WRITE_PERMISSIONS: The write permissions for the user used to connect to the event exchange. Optional.
defineEnvVar EVENT_EXCHANGE_USER_WRITE_PERMISSIONS OPTIONAL "The write permissions for the user used to connect to the event exchange" ".*"
# env: EVENT_EXCHANGE_USER_READ_PERMISSIONS: The read permissions for the user used to connect to the event exchange. Optional.
defineEnvVar EVENT_EXCHANGE_USER_READ_PERMISSIONS OPTIONAL "The read permissions for the user used to connect to the event exchange" ".*"

# env: EVENT_EXCHANGE_NAME: The name of the exchange where events are written to. Optional.
defineEnvVar EVENT_EXCHANGE_NAME OPTIONAL "The name of the exchange where events are written to"
# env: EVENT_EXCHANGE_TYPE: The type of the exchange where events are written to. Optional.
defineEnvVar EVENT_EXCHANGE_TYPE OPTIONAL "The type of the exchange where events are written to" fanout
# env: EVENT_EXCHANGE_DURABLE: Whether the exchange where events are writtenn to is durable or not. Optional.
defineEnvVar EVENT_EXCHANGE_DURABLE OPTIONAL "Whether the exchange where events are written to is durable or not" true
# env: EVENT_EXCHANGE_INTERNAL: Whether the event exchange is internal or not. Optional.
defineEnvVar EVENT_EXCHANGE_INTERNAL OPTIONAL "Whether the event  exchange is internal or not" false

# env: EVENT_AUDIT_QUEUE_NAME: The name of the event audit queue. Optional.
defineEnvVar EVENT_AUDIT_QUEUE_NAME OPTIONAL "The name of the audit queue for events"
# env: EVENT_AUDIT_QUEUE_DURABLE: Whether the event audit queue should be durable or not. Optional.
defineEnvVar EVENT_AUDIT_QUEUE_DURABLE OPTIONAL "Whether the events audit queue should be durable or not" true

# env: COMMAND_QUEUE_USER_NAME: The name of the user used to connect to the command queue. Optional.
defineEnvVar COMMAND_QUEUE_USER_NAME OPTIONAL "The login to connect to the command queue"
# env: COMMAND_QUEUE_USER_PASSWORD: The password to connect to the command queue. Optional.
defineEnvVar COMMAND_QUEUE_USER_PASSWORD OPTIONAL "The password to connect to the command queue"
# env: COMMAND_QUEUE_USER_TAGS: The tags of the user used to connect to the command queue. Optional.
defineEnvVar COMMAND_QUEUE_USER_TAGS OPTIONAL "The tags of the user used to connect the the command queue" ""
# env: COMMAND_QUEUE_USER_CONFIGURE_PERMISSIONS: The configure permissions for the user used to connect to the command queue. Optional.
defineEnvVar COMMAND_QUEUE_USER_CONFIGURE_PERMISSIONS OPTIONAL "The configure permissions for the user used to connect to the command queue" ".*"
# env: COMMAND_QUEUE_USER_WRITE_PERMISSIONS: The write permissions for the user used to connect to the command queue. Optional.
defineEnvVar COMMAND_QUEUE_USER_WRITE_PERMISSIONS OPTIONAL "The write permissions for the user used to connect to the command queue" ".*"
# env: COMMAND_QUEUE_USER_READ_PERMISSIONS: The read permissions for the user used to connect to the command queue. Optional.
defineEnvVar COMMAND_QUEUE_USER_READ_PERMISSIONS OPTIONAL "The read permissions for the user used to connect to the command queue" ".*"

# env: COMMAND_QUEUE_NAME: The name of the commands queue. Optional.
defineEnvVar COMMAND_QUEUE_NAME OPTIONAL "The name of the commands queue"
# env: COMMAND_QUEUE_DURABLE: Whether the commands queue should be durable or not. Optional.
defineEnvVar COMMAND_QUEUE_DURABLE OPTIONAL "Whether the commands queue should be durable or not" true
# env: COMMAND_DLQ_NAME: The name of the commands dead-letter queue. Optional.
defineEnvVar COMMAND_DLQ_NAME OPTIONAL "The name of the commands dead-letter queue"
# env: COMMAND_QUEUE_DLQ_DURABLE: Whether the commands dead-letter queue should be durable or not. Optional.
defineEnvVar COMMAND_DLQ_DURABLE OPTIONAL "Whether the commands dead-letter queue should be durable or not" true
# env: COMMAND_DLX_NAME: The name of the commands dead-letter exchange. Optional.
defineEnvVar COMMAND_DLX_NAME OPTIONAL "The name of the commands dead-letter exchange"
# env: COMMAND_DLX_TYPE: The type of the commands dead-letter exchange. Optional.
defineEnvVar COMMAND_DLX_TYPE OPTIONAL "The type of the commands dead-letter exchange" fanout

# env: COMMAND_EXCHANGE_USER_NAME: The login of the user used to publish commands. Optional.
defineEnvVar COMMAND_EXCHANGE_USER_NAME OPTIONAL "The login of the user used to publish commands"
# env: COMMAND_EXCHANGE_USER_PASSWORD: The password of the user used to publish commands. Optional.
defineEnvVar COMMAND_EXCHANGE_USER_PASSWORD OPTIONAL "The password of the user used to publish commands"
# env: COMMAND_EXCHANGE_USER_TAGS: The tags of the user used to publish commands. Optional.
defineEnvVar COMMAND_EXCHANGE_USER_TAGS OPTIONAL "The tags of the user used to publish commands" ""
# env: COMMAND_EXCHANGE_USER_CONFIGURE_PERMISSIONS: The configure permissions for the user used to publish commands. Optional.
defineEnvVar COMMAND_EXCHANGE_USER_CONFIGURE_PERMISSIONS OPTIONAL "The configure permissions for the user used to publish commands" ".*"
# env: COMMAND_EXCHANGE_USER_WRITE_PERMISSIONS: The write permissions for the user used to publish commands. Optional.
defineEnvVar COMMAND_EXCHANGE_USER_WRITE_PERMISSIONS OPTIONAL "The write permissions for the user used to publish commands" ".*"
# env: COMMAND_EXCHANGE_USER_READ_PERMISSIONS: The read permissions for the user used to publish commands. Optional.
defineEnvVar COMMAND_EXCHANGE_USER_READ_PERMISSIONS OPTIONAL "The read permissions for the user used to publish commands" ".*"

# env: COMMAND_EXCHANGE_NAME: The name of the command exchange. Optional.
defineEnvVar COMMAND_EXCHANGE_NAME OPTIONAL "The name of the command exchange"
# env: COMMAND_EXCHANGE_TYPE: The type of the command exchange. Optional.
defineEnvVar COMMAND_EXCHANGE_TYPE OPTIONAL "The type of the command exchange" fanout
# env: COMMAND_EXCHANGE_DURABLE: Whether the command exchange is durable or not. Optional.
defineEnvVar COMMAND_EXCHANGE_DURABLE OPTIONAL "Whether the command exchange is durable or not" true
# env: COMMAND_EXCHANGE_INTERNAL: Whether the Backoffice exchange is internal or not. Optional.
defineEnvVar COMMAND_EXCHANGE_INTERNAL OPTIONAL "Whether the Backoffice exchange is internal or not" false

# env: COMMAND_AUDIT_QUEUE_NAME: The name of the audit queue for commands. Optional.
defineEnvVar COMMAND_AUDIT_QUEUE_NAME OPTIONAL "The name of the audit queue for commands"
# env: COMMAND_AUDIT_QUEUE_DURABLE: Whether the audit queue for commands should be durable or not. Optional.
defineEnvVar COMMAND_AUDIT_QUEUE_DURABLE OPTIONAL "Whether the audit queue for commands should be durable or not" true

# env: EVENT_EXCHANGE_TO_MICROSERVICE_EVENT_QUEUE_BINDINGS: The space-separated list of bindings from the events exchange to the microservice-specific event queue. Optional.
defineEnvVar EVENT_EXCHANGE_TO_MICROSERVICE_EVENT_QUEUE_BINDINGS OPTIONAL "The space-separated list of bindings from the events exchange to the event queue"

# env: COMMAND_EXCHANGE_TO_MICROSERVICE_COMMAND_QUEUE_BINDINGS: The space-separated list of bindings from the commands exchange to the microservice-specific command queue. Optional.
defineEnvVar COMMAND_EXCHANGE_TO_MICROSERVICE_COMMAND_QUEUE_BINDINGS OPTIONAL "The space-separated list of bindings from the commands exchange to the microservice-specific command queue"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
