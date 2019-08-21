#!/usr/bin/env bash

base_dir=$(cd "$(dirname "$0")";pwd)

start_service(){
    echo "Deploy Prometheus and related services to default kubernetes cluster..."
    # install influxdb
    helm install --name=influxdb --namespace=${namespace} \
    --values=${prefix}/services/influxdb.yaml stable/influxdb
    # install webhook-dingtalk
    helm install --name=prometheus-webhook-dingtalk --namespace=${namespace} \
    --values=${prefix}/services/webhook-dingtalk.yaml ${base_dir}/charts/webhook-dingtalk/
    # install prometheus-operator
    helm install --name=prometheus --namespace=${namespace} \
    --values=${prefix}/services/prometheus.yaml stable/prometheus-operator
    # install pushgateway
    helm install --name=prometheus-pushgateway --namespace=${namespace} \
    --values=${prefix}/services/prometheus-pushgateway.yaml stable/prometheus-pushgateway
}

stop_service(){
    echo "Delete Prometheus and related services in default kubernetes cluster..."
    # delete rules, targets, alerts, exporters
    kubectl delete job influxdb-set-auth
    helm delete --purge prometheus
    helm delete --purge prometheus-webhook-dingtalk
    helm delete --purge prometheus-pushgateway
    helm delete --purge influxdb
    kubectl delete crd prometheuses.monitoring.coreos.com
    kubectl delete crd prometheusrules.monitoring.coreos.com
    kubectl delete crd servicemonitors.monitoring.coreos.com
    kubectl delete crd podmonitors.monitoring.coreos.com
    kubectl delete crd alertmanagers.monitoring.coreos.com
    echo "Delete finished!"
}

if [ "$#" -lt 2 ]; then
    echo "./deploy.sh <start/stop> <cluster-name> [namespace=monitoring]"
    exit
else
    action=$1
    cluster=$2
    namespace="monitoring"
    if [ "$#" -ge 3 ]; then
        namespace=$3
    fi
    prefix="${base_dir}/config/${cluster}"
    if [ "$action" = "start" ]; then
        start_service
    elif [ "$action" = "stop" ]; then
        stop_service
    fi
fi
