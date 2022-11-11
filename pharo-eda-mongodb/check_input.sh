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
# mod: pharo-eda-mongodb/check_input.sh
# api: public
# txt: Checks the image is launched with the required parameters.

# fun: main
# api: public
# txt: Does nothing.
# txt: Returns 0/TRUE always.
function main() {
  echo -n ""
}

# env: ADMIN_USER_PASSWORD: The password of the admin user.
defineEnvVar ADMIN_USER_PASSWORD MANDATORY "The password of the admin user"
# env: BACKUP_USER_PASSWORD: The password of the backup user.
defineEnvVar BACKUP_USER_PASSWORD MANDATORY "The password of the Backup user"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
