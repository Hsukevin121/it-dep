#!/bin/sh
{{/*
# Copyright © 2017 Amdocs, Bell Canada, AT&T
# Modifications Copyright © 2018, 2020 AT&T Intellectual Property
# Modifications Copyright (C) 2021 Nordix Foundation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
*/}}

mysqlcmd() { mysql  -h ${MYSQL_HOST} -P ${MYSQL_PORT} "$@"; };

i=5
RESULT_VARIABLE=0
echo "Check if user ${MYSQL_USER} is created in DB ${MYSQL_HOST}"
while [ $i -gt 0 ] && [ "$RESULT_VARIABLE" != 1 ]
do
  i=$(( i-1 ))
  RESULT_VARIABLE="$(mysqlcmd -uroot -p"${MYSQL_ROOT_PASSWORD}" -se "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${MYSQL_USER}')")"
  if [ "$RESULT_VARIABLE" = 1 ]; then
    echo "User ${MYSQL_USER} exists"
  else
    echo "User ${MYSQL_USER} does not exist"
    sleep 10
  fi
done
if [ "$RESULT_VARIABLE" != 1 ]; then
  exit 1
fi
for db in migration pooling policyadmin policyclamp operationshistory clampacm
do
    echo "Create DB ${db}"
    mysqlcmd -uroot -p"${MYSQL_ROOT_PASSWORD}" --execute "CREATE DATABASE IF NOT EXISTS ${db};"
    echo "Grand access for user ${MYSQL_USER}"
    mysqlcmd -uroot -p"${MYSQL_ROOT_PASSWORD}" --execute "GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${MYSQL_USER}'@'%' ;"
done
echo "Flush privileges"
mysqlcmd -uroot -p"${MYSQL_ROOT_PASSWORD}" --execute "FLUSH PRIVILEGES;"
