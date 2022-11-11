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
# mod: pharo-eda-rabbitmq/event-consumer-command-producer.sh
# api: public
# txt: Configures a local RabbitMQ for an event-consumer, command-producer PharoEDA microservice.

# Script metadata
setScriptDescription "Creates user, queues, exchanges, etc, required by PharoEDA ${MICROSERVICE_NAME}."

# env: EVENT_QUEUE_USER_NAME: The login of the user used to read events from.
defineEnvVar EVENT_QUEUE_USER_NAME MANDATORY "The login of the user used to read events from" "${MICROSERVICE_NAME}"
# env: EVENT_QUEUE_USER_PASSWORD: The password of the user used to read events from. Optional.
defineEnvVar EVENT_QUEUE_USER_PASSWORD MANDATORY "The password of the user used to read events from"
# env: EVENT_QUEUE_NAME: The name of the events queue.
defineEnvVar EVENT_QUEUE_NAME MANDATORY "The name of the queue Backoffice reads from" "events-to-${MICROSERVICE_NAME}"
# env: EVENT_DLQ_NAME: The name of the event dead-letter queue.
defineEnvVar EVENT_DLQ_NAME MANDATORY "The name of the event dead-letter queue" "unprocessed-events-in-${MICROSERVICE_NAME}"
# env: EVENT_DLX_NAME: The name of the dead-letter exchange for unprocessed events.
defineEnvVar EVENT_DLX_NAME MANDATORY "The name of the dead-letter exchange for unprocessed events" "unprocessed-events-in-${MICROSERVICE_NAME}"

# env: COMMAND_EXCHANGE_USER_NAME: The login of the user used to publish commands.
defineEnvVar COMMAND_EXCHANGE_USER_NAME MANDATORY "The login of the user used to publish commands" "${MICROSERVICE_NAME}"
# env: COMMAND_EXCHANGE_USER_PASSWORD: The password of the user used to publish commands.
defineEnvVar COMMAND_EXCHANGE_USER_PASSWORD MANDATORY "The password of the user used to publish commands"

# env: COMMAND_EXCHANGE_NAME: The name of the command exchange.
defineEnvVar COMMAND_EXCHANGE_NAME MANDATORY "The name of the command exchange" "commands-from-${MICROSERVICE_NAME}"
# env: COMMAND_AUDIT_QUEUE_NAME: The name of the audit queue for commands.
defineEnvVar COMMAND_AUDIT_QUEUE_NAME OPTIONAL "The name of the audit queue for commands" "all-${COMMAND_EXCHANGE_NAME}"

source /usr/local/bin/generic-consumer-producer.sh
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
