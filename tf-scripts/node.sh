#!/bin/bash -v

# Copyright 2016 Joe Beda
#
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

# Retry kubeadm join while we wait for the master to be up.
#
# This should be done inside of kubeadm.  Fixed but waiting on next release. See
# https://github.com/kubernetes/kubernetes/issues/35533
for i in {1..50}; do
  if kubeadm join --token=${token} ${master-ip}:6443 --discovery-token-unsafe-skip-ca-verification ; then
    break
  else
    sleep 15
  fi
done
