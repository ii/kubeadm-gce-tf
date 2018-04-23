#!/bin/sh
if [ -z "$1" ] ; then
    WEBHOOK_URL=${webhook_url}
else
    WEBHOOK_URL=$1
fi

echo You need a version of kubeadm that supports audit-webhook configuration
echo See: https://github.com/kubernetes/kubernetes/pull/62826
cd /usr/bin
curl -O https://storage.googleapis.com/artifacts.ii-coop.appspot.com/kubeadm
chmod +x kubeadm

mkdir -p /etc/kubernetes

cat <<EOWEBHOOK > /etc/kubernetes/audit-webhook.yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: $WEBHOOK_URL
  name: hit-config
contexts:
- context:
    cluster: hit-config
    user: ""
  name: webhook
current-context: webhook
users: []
preferences: {}
EOWEBHOOK

cat <<EOPOLICY > /etc/kubernetes/audit-policy.yaml
apiVersion: audit.k8s.io/v1beta1
kind: Policy
omitStages:
  - "RequestReceived"
rules:
- level: RequestResponse
  resources:
  - group: "" # core
    resources: ["pods", "secrets"]
  - group: "extensions"
    resources: ["deployments"]
EOPOLICY

# If we need a cloud-config, it needs to be "/etc/kubernetes/cloud-config"
# https://github.com/kubernetes/kubernetes/blob/master/pkg/cloudprovider/providers/gce/gce.go#L195
cat <<EOKUBEADM > /etc/kubernetes/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
cloudProvider: gce
token: ${token}
auditPolicy:
  path: "/etc/kubernetes/audit-policy.yaml"
  webhookConfigPath: "/etc/kubernetes/audit-webhook.yaml"
  webhookInitialBackoff: "50s"
  logDir: "/config"
  logMaxAge: 10
networking:
  serviceSubnet: "${service-cidr}"
featureGates:
  Auditing: true
EOKUBEADM

