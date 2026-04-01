#!/bin/bash -xe

# declare
EKS_CLUSTER_NAME="md-rc"
AWS_CREDENTIAL_PROFILE="md-rc"
REGION="ap-northeast-2"
NAMESPACE="bms"
WAIT_RESOURCE_CREATION_IN_SEC=300

K8S_CONTEXT="arn:aws:eks:ap-northeast-2:741328073657:cluster/$EKS_CLUSTER_NAME"
YAML_DIR_PATH="$WORKSPACE/bms/deploy/production"

# arguments
DOCKER_IMAGE_TAG=$1

# cmd
AWS="aws --profile $AWS_CREDENTIAL_PROFILE --region $REGION"
KUBECTL="kubectl --context $K8S_CONTEXT"

setEKSContext() {
	echo "[INFO] set eks context to $K8S_CONTEXT..."

	$AWS eks update-kubeconfig --name $EKS_CLUSTER_NAME

	CURRENT_CONTEXT=`kubectl config current-context`

	if [ "$CURRENT_CONTEXT" != "$K8S_CONTEXT" ]; then
		echo "[ERROR] invalid eks context: $CURRENT_CONTEXT"
		exit 1
	fi

	echo "[INFO] set eks context to $CURRENT_CONTEXT done"
}

generateDeploymentYAMLs() {
	echo "[INFO] generate deployment yaml..."

	sed "s/{TAG}/$DOCKER_IMAGE_TAG/g" $YAML_DIR_PATH/deploy.calculate-balance-difference-scheduler.template.yaml > $YAML_DIR_PATH/deploy.calculate-balance-difference-scheduler.yaml
	sed "s/{TAG}/$DOCKER_IMAGE_TAG/g" $YAML_DIR_PATH/deploy.calculate-platform-data-scheduler.template.yaml > $YAML_DIR_PATH/deploy.calculate-platform-data-scheduler.yaml
	sed "s/{TAG}/$DOCKER_IMAGE_TAG/g" $YAML_DIR_PATH/deploy.calculate-report-scheduler.template.yaml > $YAML_DIR_PATH/deploy.calculate-report-scheduler.yaml
	sed "s/{TAG}/$DOCKER_IMAGE_TAG/g" $YAML_DIR_PATH/deploy.generate-time-statistic-report-scheduler.template.yaml > $YAML_DIR_PATH/deploy.generate-time-statistic-report-scheduler.yaml
	sed "s/{TAG}/$DOCKER_IMAGE_TAG/g" $YAML_DIR_PATH/deploy.management.template.yaml > $YAML_DIR_PATH/deploy.management.yaml
	sed "s/{TAG}/$DOCKER_IMAGE_TAG/g" $YAML_DIR_PATH/deploy.platform.template.yaml > $YAML_DIR_PATH/deploy.platform.yaml

	echo "[INFO] generate deployment yaml done"
}

applyNamespace() {
	echo "[INFO] apply bms namespace..."

	$KUBECTL apply -f $YAML_DIR_PATH/namespace.yaml

	echo "[INFO] apply bms namespace done"
}

applyNginxIngressController() {
	echo "[INFO] apply nginx-ingress-controller..."

	$KUBECTL apply -f $YAML_DIR_PATH/nginx-ingress-controller.yaml
	timeout $WAIT_RESOURCE_CREATION_IN_SEC $KUBECTL rollout status deploy nginx-ingress-controller -w --namespace $NAMESPACE

	echo "[INFO] apply nginx-ingress-controller done"
}

applyRedisService() {
	echo "[INFO] apply redis service..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.redis.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  $KUBECTL rollout status deploy redis -w --namespace $NAMESPACE

	echo "[INFO] apply redis service done"
}

applyFilebeatDaemonSet() {
	echo "[INFO] apply filebeat daemonSet..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.filebeat.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC $KUBECTL rollout status ds/filebeat-daemonset -w --namespace $NAMESPACE

	echo "[INFO] apply filebeat daemonSet done"
}

applyLogstashService() {
	echo "[INFO] apply logstash service..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.logstash.yaml
	timeout $WAIT_RESOURCE_CREATION_IN_SEC $KUBECTL rollout status deploy logstash-deployment -w --namespace $NAMESPACE

	echo "[INFO] apply logstash service done"
}

applyManagementService() {
	echo "[INFO] apply bms management service..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.management.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  $KUBECTL rollout status deploy bms-management-deployment -w --namespace $NAMESPACE

	echo "[INFO] apply bms management done"
}

applyPlatformService() {
	echo "[INFO] apply bms platform service..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.platform.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  $KUBECTL rollout status deploy bms-platform-deployment -w --namespace $NAMESPACE

	echo "[INFO] apply bms platform done"
}

applyCalculatePlatformDataSchedulerDeployment() {
	echo "[INFO] apply bms calculate platform data scheduler deployment..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.calculate-platform-data-scheduler.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  $KUBECTL rollout status deploy calculate-platform-data-scheduler-deployment -w --namespace $NAMESPACE

	echo "[INFO] apply bms calculate platform data scheduler deployment done"
}

applyCalculateReportSchedulerDeployment() {
	echo "[INFO] apply bms calculate report scheduler deployment..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.calculate-report-scheduler.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  $KUBECTL rollout status deploy calculate-report-scheduler-deployment -w --namespace $NAMESPACE

	echo "[INFO] apply bms calculate report scheduler deployment done"
}

applyCalculateBalanceDifferenceSchedulerDeployment() {
	echo "[INFO] apply bms calculate balance difference scheduler deployment..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.calculate-balance-difference-scheduler.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  $KUBECTL rollout status deploy calculate-balance-difference-scheduler-deployment -w --namespace $NAMESPACE

	echo "[INFO] apply bms calculate balance difference scheduler deployment done"
}

applyGenerateTimeStatisticReportSchedulerDeployment() {
	echo "[INFO] apply bms generate time statistic report scheduler deployment..."

	$KUBECTL apply -f $YAML_DIR_PATH/deploy.generate-time-statistic-report-scheduler.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  $KUBECTL rollout status deploy generate-time-statistic-report-scheduler-deployment -w --namespace $NAMESPACE

	echo "[INFO] apply bms generate time statistic report scheduler deployment done"
}

applyMetricbeatDaemonSet() {
	echo "[INFO] apply bms metricbeat daemonSet..."

	$KUBECTL apply -f $YAML_DIR_PATH/metricbeat.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  $KUBECTL rollout status ds/metricbeat -w --namespace $NAMESPACE

	echo "[INFO] apply bms metricbeat daemonSet done"
}

# exit when any command failed
set -e
set -o pipefail

# set eks context
setEKSContext

# main
generateDeploymentYAMLs

applyNamespace
applyNginxIngressController
applyRedisService
applyFilebeatDaemonSet
applyLogstashService
applyMetricbeatDaemonSet

applyManagementService
applyPlatformService
applyCalculatePlatformDataSchedulerDeployment
applyCalculateReportSchedulerDeployment
applyCalculateBalanceDifferenceSchedulerDeployment
applyGenerateTimeStatisticReportSchedulerDeployment

exit 0
