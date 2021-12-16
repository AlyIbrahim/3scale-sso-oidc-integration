#!/bin/bash
# Maintained by Aly Ibrahim
# Github Repo: https://github.com/AlyIbrahim/3scale-sso-oidc-integration.git

echo -n | openssl s_client -connect $SSO_HOST:$SSO_PORT -servername $SSO_HOST --showcerts | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > customCA.pem


result=$(curl -o /dev/null -s -w "%{http_code}\n" https://$SSO_HOST/auth/realms/master --cacert customCA.pem)

if [ $result = 200 ]
	then echo "SSO Certificate Verified"
else
	echo "SSO Certificate Not Correct"
	exit 128
fi

ZYNC_QUE=$(oc get pods --field-selector=status.phase==Running -l deploymentConfig="zync-que" -o jsonpath="{.items[0].metadata.name}" -n $NAMESPACE)

oc exec $ZYNC_QUE -n $NAMESPACE -- cat /etc/pki/tls/cert.pem > zync.pem > /dev/null 2>&1

cat customCA.pem >> zync.pem

ca_configmap=$(kubectl get configmap zync-ca-bundle -n $NAMESPACE)

if [ -n "$ca_configmap" ]
then
	kubectl delete configmap zync-ca-bundle -n $NAMESPACE > /dev/null 2>&1
fi

oc create configmap zync-ca-bundle --from-file=./zync.pem -n $NAMESPACE > /dev/null 2>&1

oc set volume dc/zync-que --add --name=zync-ca-bundle --mount-path /etc/pki/tls/zync/zync.pem --sub-path zync.pem --source='{"configMap":{"name":"zync-ca-bundle","items":[{"key":"zync.pem","path":"zync.pem"}]}}' --overwrite -n $NAMESPACE > /dev/null 2>&1

oc set env dc/zync-que SSL_CERT_FILE=/etc/pki/tls/zync/zync.pem -n $NAMESPACE > /dev/null 2>&1

oc rollout latest dc/zync-que -n $NAMESPACE > /dev/null 2>&1

rm -rf zync.pem
rm -rf customCA.pem
