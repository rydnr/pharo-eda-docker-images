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
# mod: pharo-eda-rabbitmq/command-consumer-event-producer.sh
# api: public
# txt: Configures a local RabbitMQ for an command-consumer, event-producer PharoEDA microservice.

# Script metadata
setScriptDescription "Configures a local RabbitMQ for an command-consumer, event-producer PharoEDA microservice."

# env: COMMAND_QUEUE_USER_NAME: The name of the user used to connect to the command queue.
defineEnvVar COMMAND_QUEUE_USER_NAME MANDATORY "The name of the user used to connect to the command queue" "${MICROSERVICE_NAME}"
# env: COMMAND_QUEUE_USER_PASSWORD: The password of the user used to connect to the command queue.
defineEnvVar COMMAND_QUEUE_USER_PASSWORD MANDATORY "The password of the user the used to connect to the command queue" # env

# env: COMMAND_QUEUE_NAME: The name of the commands queue.
defineEnvVar COMMAND_QUEUE_NAME MANDATORY "The name of the commands queue" "commands-to-${MICROSERVICE_NAME}"
# env: COMMAND_DLQ_NAME: The name of the commands dead-letter queue.
defineEnvVar COMMAND_DLQ_NAME MANDATORY "The name of the commands dead-letter queue" "unprocessed-commands-in-${MICROSERVICE_NAME}"
# env: COMMAND_DLX_NAME: The name of the commands dead-letter exchange.
defineEnvVar COMMAND_DLX_NAME MANDATORY "The name of the commands dead-letter exchange" "unprocessed-commands-in-${MICROSERVICE_NAME}"

# env: EVENT_EXCHANGE_USER_NAMEO: The name of the user used to connect to the event exchange.
defineEnvVar EVENT_EXCHANGE_USER_NAME MANDATORY "The name of the user used to connect to the event exchange" "${MICROSERVICE_NAME}"
# env: EVENT_EXCHANGE_USER_PASSWORD: The password of the user used to connect to the event exchange.
defineEnvVar EVENT_EXCHANGE_USER_PASSWORD MANDATORY "The password of the user used to connect to the event exchange"

# env: EVENT_EXCHANGE_NAME: The name of the exchange where events are written to.
defineEnvVar EVENT_EXCHANGE_NAME MANDATORY "The name of the exchange where events are written to" "events-from-${MICROSERVICE_NAME}"
# env: EVENT_AUDIT_QUEUE_NAME: The name of the event audit queue.
defineEnvVar EVENT_AUDIT_QUEUE_NAME MANDATORY "The name of the audit queue for events" "all-${EVENT_EXCHANGE_NAME}"

source /usr/local/bin/generic-consumer-producer.sh
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
