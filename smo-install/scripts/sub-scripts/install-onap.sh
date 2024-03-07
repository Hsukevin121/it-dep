#!/bin/bash

###
# ============LICENSE_START=======================================================
# ORAN SMO Package
# ================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# 
###

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
cd $SCRIPT_PATH

helm cm-push ../packages/strimzi-kafka-operator-helm-3-chart-0.36.1.tgz local
helm repo update
helm install strimzi-kafka-operator local/strimzi-kafka-operator --namespace strimzi-system --version 0.36.1 --set watchAnyNamespace=true --create-namespace

kubectl create namespace onap
echo '### Installing ONAP part ###'
helm deploy --debug onap local/onap --namespace onap -f $1 --set global.persistence.mountPath="/dockerdata-nfs/deployment-$2" --set dmaap.message-router.message-router-zookeeper.persistence.mountPath="/dockerdata-nfs/deployment-$2" --set dmaap.message-router.message-router-kafka.persistence.mountPath="/dockerdata-nfs/deployment-$2"
