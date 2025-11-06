# sm-scaling

> **NOTE:**
> Any changes made to README.md will be overwritten by helm-docs

![Version: 0.0.4](https://img.shields.io/badge/Version-0.0.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 7.17.0-1307568](https://img.shields.io/badge/AppVersion-7.17.0--1307568-informational?style=flat-square)

## Overview

A helm chart for deploying a simple scaling service

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalAnnotations | object | `{}` | Additional deployment annotations |
| additionalEnv | object | `{}` | Additional environment variables |
| additionalLabels | object | `{}` | Additional deployment labels |
| additionalPodAnnotations | object | `{}` | Additional pod annotations |
| additionalPodLabels | object | `{}` | Additional pod labels |
| additionalVolumeMounts | list | `[]` | additional volumeMounts to make available on scaler pod |
| additionalVolumes | list | `[]` | additional volumes to make available on scaler pod |
| backends.database.enabled | bool | `false` | Enable database backend |
| backends.database.extraMetrics.configMap.data | object | `{}` | ConfigMap data for extra metrics |
| backends.database.extraMetrics.configMap.name | string | `"scaler-extra-metrics-config"` | ConfigMap name for extra metrics |
| backends.database.extraMetrics.enabled | bool | `false` | Enable extra metrics |
| backends.database.secretName | string | `"my-database-secret"` | Database backend secret name |
| backends.database.stageNames | object | `{}` | Stage name and ID from DB |
| backends.prometheus.enabled | bool | `true` | Enable prometheus backend |
| backends.prometheus.url | string | `"http://prometheus.default.svc.cluster.local"` | Prometheus backend url |
| backends.resourceManagerMetrics.enabled | bool | `false` | Enable resource manager metrics backend |
| backends.resourceManagerMetrics.url | string | `"http://resource-manager-metrics:8080/metrics"` | Resource manager metrics backend url |
| global.imagePullSecrets | list | `[]` | global imagePullSecrets |
| global.scaler.image.registry | string | `"speechmaticsproduction.azurecr.io"` | Registry to use for scaler imageßßß |
| image | object | `{"repository":"scaler"}` | These values will take precedence over the global.scaler values if provided. |
| imagePullSecrets | list | `[]` |  |
| livenessProbe | object | `{}` | Liveness probe for the scaler server |
| nodeSelector | object | `{}` | nodeSelector for the scaler |
| readinessProbe | object | `{}` | Readiness probe for the scaler server |
| replicas | int | `1` | Number of replicas |
| resources | object | `{}` | Resource requests and limits for the scaler server |
| securityContext | object | `{"fsGroup":20000,"runAsGroup":10000,"runAsUser":10000}` | Security context for the scaler |
| terminationGracePeriodSeconds | int | `30` | Termination grace period for the pod |
| tolerations | list | `[]` | tolerations for the scaler |

## Usage

### Backends

#### Prometheus backend

The default backend enabled for scaling metrics is a prometheus server, it is assumed that the prometheus server is running and is accessible from inside the cluster. To configure the prometheus backend, you need to configure the `backends.prometheus.url` value.

Once configured, the scaler will use the prometheus server to fetch scaling metrics whenever a metric is configured for a prometheus backend.

The scaler will also expose its own metrics for scraping, upon restart it will use the saved metrics to initialize all the metric values.

#### Database backend

To use a database backend, you need to have a PostgreSQL database running with connection details saved in the cluster
as a secret. The secret should have a single key `conn_string` containing the connection string. To enable database backend set `backends.database.enabled` to `true` and set DB connection string secret name in `backends.database.secretName` helm values.

##### Extra metrics

The scaler can also expose metrics to prometheus even if no deployments are configured to use them for scaling purposes, to do this, you need to configure the `backends.database.extraMetrics` value.

This requires `backends.database.extraMetrics.enabled` to be set to `true` and `backends.database.extraMetrics.configMap.data` to be set to a yaml map of metric name to config, this follows the same format as postgres exporter see [here](https://github.com/prometheus-community/postgres_exporter/blob/release-0.11/queries.yaml) for examples.

The scaler will then expose these metrics to prometheus for scraping.

N.B. these extra metrics will also need the prometheus backend configured to work.

#### Resource manager metrics backend

Resource manager metrics is a Speechmatics service which is part of inference controller applications deployed using `sm-resource-manager` helm chart. Resource manager metrics backend can be used to fetch sessiongroup related metrics such as `model_set_usage`, `resource_usage` , etc.

To enable resource manager metrics backend set `backends.resourceManagerMetrics.enabled` to `true` and configure the service URL using ``backends.resourceManagerMetrics.url` helm values.

### Usage

#### Scaling Deployments

For a deployment to be scaled, it must have the following annotations:

- `sm.scaler.enabled` - Set to true to enable scaling for this deployment
- `sm.scaler.config` - The scaling config for the deployment supplied as a json string

e.g

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: my-deployment
    annotations:
        speechmatics.io/scaling.enabled: "true"
        speechmatics.io/scaling.config: |
          {
            "min_replicas": 1,
            "max_replicas": 10,
            "cooldown_period": 60,
            "max_step": 5,
            "metrics": [
              {
                  "name": "queue_depth",
                  "backend": "queue",
                  "properties": {"queue_stage": "prefetch"},
                  "threshold": 5,
                  "window": 300
              },
              {
                  "name": "my_metric",
                  "backend": "prometheus",
                  "properties": {"query": "my_metric{pod_name=\"my-pod-name\"}"},
                  "threshold": 5,
                  "window": 300
              }
            ]
          }
   
```

- `min_replicas` - The minimum number of replicas to scale to
- `max_replicas` - The maximum number of replicas to scale to
- `cooldown_period` - The cooldown period in seconds to wait before scaling down after scaling up (0 means no cooldown)
- `max_step` - The maximum number of replicas to scale by in one step either up or down (0 means no limit)
- `metrics` - The list of metrics to use for scaling
    - `name` - The name of the metric (unique per deployment)
    - `backend` - The backend to use for the metric e.g. `queue` or `prometheus`
    - `properties` - The properties to pass to the backend (optional)
    - `threshold` - The threshold to use for scaling
    - `window` - The window to use for scaling (in seconds) - this is the time period over which the metric value is averaged

