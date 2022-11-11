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
# mod: pharo-eda-mongodb/generic-eventstore-client.sh
# api: public
# txt: Configures a MongoDB instance for PharoEDA.

DW.import mongodb

# Script metadata
# setScriptDescription "Bootstraps a MongoDB server for PharoEDA.";

# env: MICROSERVICE_NAME: The name of the microservice.
defineEnvVar MICROSERVICE_NAME MANDATORY "The name of the microservice"

# env: ADMIN_USER_NAME: The name of the admin user.
defineEnvVar ADMIN_USER_NAME MANDATORY "The name of the admin user"
# env: ADMIN_USER_PASSWORD: The password of the admin user.
defineEnvVar ADMIN_USER_PASSWORD MANDATORY "The password of the admin user"

# env: AUTHENTICATION_DATABASE: The name of authentication database.
defineEnvVar AUTHENTICATION_DATABASE MANDATORY "The name of the authentication database" "admin"
# env: AUTHENTICATION_MECHANISM: The authentication mechanism.
defineEnvVar AUTHENTICATION_MECHANISM MANDATORY "The authentication mechanism"

# env: EVENTSTORE_USER_NAME: The user used to access the EventStore database in MongoDB.
defineEnvVar EVENTSTORE_USER_NAME MANDATORY "The user used to access the EventStore database in MongoDB"
# env: EVENTSTORE_USER_PASSWORD: The password of the EVENTSTORE_USER user.
defineEnvVar EVENTSTORE_USER_PASSWORD MANDATORY "The password of the EVENTSTORE_USER user"
# env: EVENTSTORE_DATABASE: The name of the EventStore database. Defaults to "eventstore".
defineEnvVar EVENTSTORE_DATABASE MANDATORY "The name of the EventStore database" "eventstore"

# env: TEMPORARY_COLLECTION_NAME: A temporary collection used to ensure the databases get created successfully. Defaults to removeme.
defineEnvVar TEMPORARY_COLLECTION_NAME MANDATORY "A temporary collection used to ensure the databases get created successfully." "removeme"

addError CANNOT_ADD_PROJECTIONS_DATABASE "Cannot create the Projections database ${PROJECTIONS_DATABASE}"
addError CANNOT_REMOVE_EVENTSTORE_TEMPORARY_COLLECTION "Cannot remove the temporary collection in ${EVENTSTORE_DATABASE} database"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
