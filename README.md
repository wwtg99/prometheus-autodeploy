Prometheus Deploy
=================

# Introduction

This project is used to deploy prometheus monitoring related services.

Full introduction please refer to [this blog](https://zhuanlan.zhihu.com/p/79561704). 详细介绍请参考[这篇文章](https://zhuanlan.zhihu.com/p/79561704)。

# Structure

```
- charts  # additional charts
|-- rules  # create prometheus rule for prometheus
|-- scrape-targets  # create service monitor for prometheus
|-- webhook-dingtalk  # dingtalk webhook for alert manager
- config  # charts configuration
|-- example-cluster  # kubernetes cluster name
  |-- services  # services config for this cluster
  |-- rules  # rules config for this cluster
  |-- targets  # targets config for this cluster
  |-- exporters  # exporters config for this cluster
- deploy.sh  # deploy script
```

## Convention

Place your own charts in `charts` directory.
Place chart config files in `config/<cluster-name>` directory.

# Usage

## Deploy monitoring system in kubernetes cluster

1. Create a namespace, for example `monitoring`
2. Create a cluster directory in `config` directory, for example `example-cluster`
3. Create persistent storage for influxDB or use existing one, for example apply `storage.yaml` in `example-cluster` to your cluster
4. Update chart config files for your requirements in your cluster config `services` directory
5. Deploy services by `./deploy.sh start <cluster-name>`
6. Deploy other exporters, targets and rules by helm, for example `helm install --name influxdb-target --namespace monitoring -f config/example-cluster/targets/influxdb-target.yaml charts/scrape-targets`

For automation pipeline, you should write your own deploy script to start/stop/update services.

## Delete monitoring system in kubernetes cluster

1. Delete service by `./deploy.sh stop <cluster-name>`
2. Delete other helm release by helm, for example `helm delete --purge influxdb-target`

# Configuration

## InfluxDB

Check [InfluxDB chart](https://github.com/helm/charts/tree/master/stable/influxdb) for more information, configuration can be viewed at [here](https://github.com/helm/charts/blob/master/stable/influxdb/values.yaml) and docs at [here](https://docs.influxdata.com/influxdb/v1.7/administration/config/).

## Prometheus Operator

Check [Prometheus-Operator chart](https://github.com/helm/charts/tree/master/stable/prometheus-operator) for more information, configuration can be viewed at project page and [API docs](https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md).

## Prometheus Pushgateway

Check [Prometheus-Pushgateway chart](https://github.com/helm/charts/tree/master/stable/prometheus-pushgateway) for more information, configuration can be viewed at project page.

## Alert Integrations

[Webhook-Dingtalk](https://github.com/timonwong/prometheus-webhook-dingtalk) is a third-party alert integration for dingtalk and alert manager. The configuration can be found at [here](https://theo.im/blog/2017/10/16/release-prometheus-alertmanager-webhook-for-dingtalk/). 

There are several alert integrations for alert manager [here](https://prometheus.io/docs/operating/integrations/#alertmanager-webhook-receiver).

## Exporters

We can find and re-use other exporters from [here](https://prometheus.io/docs/instrumenting/exporters/). If they do not meet our requirements, we can develop our own exporters *[docs](https://prometheus.io/docs/instrumenting/writing_exporters/)*.

## Scrape Targets

Add scrape targets to prometheus, docs at [here](https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#servicemonitorspec).

| Parameter | Description | Default
| --------- | ----------- | -------
| nameOverride | override name | `""` |
| fullnameOverride | override fullname | `""` |
| selector | Selector to select Endpoints objects. Use [label select object](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#labelselector-v1-meta). Required | `{}` |
| endpoints | A list of endpoints allowed as part of this ServiceMonitor. Required. | `{}` |
| namespaceSelector | Selector to select which namespaces the Endpoints objects are discovered from. | `{}` |
| jobLabel | The label to use to retrieve the job name from. | `""` |
| targetLabels | TargetLabels transfers labels on the Kubernetes Service onto the target. | `[]` |
| podTargetLabels | PodTargetLabels transfers labels on the Kubernetes Pod onto the target. | `[]` |
| sampleLimit | SampleLimit defines per-scrape limit on number of scraped samples that will be accepted. | `null` |

## Rules

Add rules to prometheus, docs at [here](https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#prometheusrulespec).

| Parameter | Description | Default
| --------- | ----------- | -------
| nameOverride | override name | `""` |
| fullnameOverride | override fullname | `""` |
| groups[0].name | Prometheus rule name | `""` |
| groups[0].rules | Prometheus rule object list, [object ref](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/#rule) | `[]` |

# Troubleshooting

## Enable scrape from kube-proxy

Change metrics bind address to `metricsBindAddress: 0.0.0.0:10249` of kube-proxy config map.

```
kubectl -n kube-system edit cm kube-proxy
```

```
apiVersion: v1
data:
  config.conf: |-
    apiVersion: kubeproxy.config.k8s.io/v1alpha1
    kind: KubeProxyConfiguration
    # ...
    # metricsBindAddress: 127.0.0.1:10249
    metricsBindAddress: 0.0.0.0:10249
    # ...
  kubeconfig.conf: |-
    # ...
kind: ConfigMap
metadata:
  labels:
    app: kube-proxy
  name: kube-proxy
  namespace: kube-system
```

# References

- [Prometheus Docs](https://prometheus.io/docs/introduction/overview/)
- [Grafana Docs](https://grafana.com/docs/)
- [InfluxDB Docs](https://docs.influxdata.com/influxdb/v1.7/)
- [InfluxDB Chart](https://github.com/helm/charts/tree/master/stable/influxdb)
- [Prometheus-Operator](https://github.com/coreos/prometheus-operator)
- [Prometheus-Operator Chart](https://github.com/helm/charts/tree/master/stable/prometheus-operator)
- [Prometheus-Operator API Docs](https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md)
- [Prometheus-Pushgateway Chart](https://github.com/helm/charts/tree/master/stable/prometheus-pushgateway)
- [Prometheus Webhook Dingtalk](https://github.com/timonwong/prometheus-webhook-dingtalk)
