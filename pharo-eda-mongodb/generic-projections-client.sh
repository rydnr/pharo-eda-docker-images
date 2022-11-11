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

# fun: add_Projections_collection_if_necessary collection cannotAddCollectionErrorLabel collectionDoesNotExistErrorLabel
# api: public
# txt: Adds a collection in the Projections database, if necessary.
# opt: collection: The name of the collection.
# opt: cannotAddCollectionErrorLabel: The error label when the collection cannot be added.
# opt: collectionDoesNotExistErrorLabel: The error label when the collection is missing even after being supposedly created.
# txt: Returns 0/TRUE always, but can exit if the collection cannot be added.
# use: add_Projections_collection_if_necessary MyCollectionFind CANNOT_ADD_MYCOLLECTION MYCOLLECTION_DOES_NOT_EXIST;
function add_Projections_collection_if_necessary() {
  local _collection="${1}"
  checkNotEmpty collection "${_collection}" 1
  local _cannotAddCollectionErrorLabel="${2}"
  checkNotEmpty cannotAddCollectionErrorLabel "${_cannotAddCollectionErrorLabel}" 2
  local _collectionDoesNotExistErrorLabel="${3}"
  checkNotEmpty collectionDoesNotExistErrorLabel "${_collectionDoesNotExistErrorLabel}" 3

  addMongodbCollectionIfNecessary \
    "${PROJECTIONS_DATABASE}" \
    "${_collection}" \
    "${_cannotAddCollectionErrorLabel}" \
    "${_collectionDoesNotExistErrorLabel}" \
    "${ADMIN_USER_NAME}" \
    "${ADMIN_USER_PASSWORD}" \
    "${AUTHENTICATION_DATABASE}" \
    "${AUTHENTICATION_MECHANISM}"
}

# fun: add_Projections_role_if_necessary roleName collection action cannotAddRoleErrorLabel roleDoesNotExistErrorLabel
# api: public
# txt: Adds a role in the Projections database, if necessary.
# opt: roleName: The role name.
# opt: collection: The name of the collection.
# opt: action: The role action.
# opt: cannotAddRoleErrorLabel: The error label when the role cannot be added.
# opt: roleDoesNotExistErrorLabel: The error label when the role is missing even after being supposedly created.
# txt: Returns 0/TRUE always, but can exit if the role cannot be added.
# use: add_Projections_role_if_necessary MyCollectionFind MyCollection find CANNOT_ADD_MYCOLLECTIONFIND_ROLE MYCOLLECTIONFIND_ROLE_DOES_NOT_EXIST;
function add_Projections_role_if_necessary() {
  local _roleName="${1}"
  checkNotEmpty roleName "${_roleName}" 1
  local _collection="${2}"
  checkNotEmpty collection "${_collection}" 2
  local _action="${3}"
  checkNotEmpty action "${_action}" 3
  local _cannotAddRoleErrorLabel="${4}"
  checkNotEmpty cannotAddRoleErrorLabel "${_cannotAddRoleErrorLabel}" 4
  local _roleDoesNotExistErrorLabel="${5}"
  checkNotEmpty roleDoesNotExistErrorLabel "${_roleDoesNotExistErrorLabel}" 5

  addMongodbRoleIfNecessary \
    "${_roleName}" \
    "[ { resource: { db: '${PROJECTIONS_DATABASE}', collection: '${_collection}' }, actions: [ '${_action}' ] } ]" \
    '[]' \
    "${_cannotAddRoleErrorLabel}" \
    "${_roleDoesNotExistErrorLabel}" \
    "${AUTHENTICATION_DATABASE}" \
    "${ADMIN_USER_NAME}" \
    "${ADMIN_USER_PASSWORD}" \
    "${AUTHENTICATION_DATABASE}" \
    "${AUTHENTICATION_MECHANISM}"
}

# fun: add_Projections_index_if_necessary indexName indexSpec collection cannotCreateIndexErrorLabel indexDoesNotExistErrorLabel
# api: public
# txt: Creates an index on the Projections database, if necessary.
# opt: indexName: The name of the index.
# opt: indexSpec: The index specification.
# opt: collection: The collection name.
# opt: cannotCreateIndexErrorLabel: The label to use when the index cannot be created.
# opt: indexDoesNotExistErrorLabel: The label to use when the index is still missing after being supposedly created.
# txt: Returns 0/TRUE always, but cat exit if the index cannot be created.
# use: add_Projections_index_if_necessary id "${ id: 1 }" MyProjection CANNOT_ADD_MYPROJECTION_ID_INDEX MYPROJECTION_ID_INDEX_DOES_NOT_EXIST;
function add_Projection_index_if_necessary() {
  local _indexName="${1}"
  checkNotEmpty indexName "${_indexName}" 1
  local _indexSpec="${2}"
  checkNotEmpty indexSpec "${_indexSpec}" 2
  local _collection="${3}"
  checkNotEmpty collection "${_collection}" 3
  local _cannotCreateIndexErrorLabel="${4}"
  checkNotEmpty cannotCreateIndexErrorLabel "${_cannotCreateIndexErrorLabel}" 4
  local _indexDoesNotExistErrorLabel="${5}"
  checkNotEmpty indexDoesNotExistErrorLabel "${_indexDoesNotExistErrorLabel}" 5

  addMongodbIndexIfNecessary \
    "${_indexName}" \
    "${_indexSpec}" \
    "${PROJECTIONS_DATABASE}" \
    "${_collection}" \
    "${_cannotCreateIndexErrorLabel}" \
    "${_indexDoesNotExistErrorLabel}" \
    "${ADMIN_USER_NAME}" \
    "${ADMIN_USER_PASSWORD}" \
    "${AUTHENTICATION_DATABASE}" \
    "${AUTHENTICATION_MECHANISM}"
}

# Script metadata
setScriptDescription "Bootstraps a MongoDB server for PharoEDA."

# env: PROJECTIONS_DATABASE: The name of the Projections database. Defaults to "projections".
defineEnvVar PROJECTIONS_DATABASE MANDATORY "The name of the Projections database" "projections"

# env: TEMPORARY_COLLECTION_NAME: A temporary collection used to ensure the databases get created successfully. Defaults to removeme.
defineEnvVar TEMPORARY_COLLECTION_NAME MANDATORY "A temporary collection used to ensure the databases get created successfully." "removeme"

# env: ADMIN_USER_NAME: The name of the admin user.
defineEnvVar ADMIN_USER_NAME MANDATORY "The name of the admin user"
# env: ADMIN_USER_PASSWORD: The password of the admin user.
defineEnvVar ADMIN_USER_PASSWORD MANDATORY "The password of the admin user"

# env: AUTHENTICATION_DATABASE: The name of authentication database.
defineEnvVar AUTHENTICATION_DATABASE MANDATORY "The name of the authentication database" "admin"
# env: AUTHENTICATION_MECHANISM: The authentication mechanism.
defineEnvVar AUTHENTICATION_MECHANISM MANDATORY "The authentication mechanism"

# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
