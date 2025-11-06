# sm-realtime

> **NOTE:**
> Any changes made to README.md will be overwritten by helm-docs

![Version: 0.6.0](https://img.shields.io/badge/Version-0.6.0-informational?style=flat-square) ![AppVersion: 1.34.6-1307912](https://img.shields.io/badge/AppVersion-1.34.6--1307912-informational?style=flat-square)

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../sm-flow | flow(sm-flow) | ~0.5.0 |
| file://../sm-gpu | inferenceServerCustom(sm-gpu) | ~3.19.0 |
| file://../sm-gpu | inferenceServerStandardAll(sm-gpu) | ~3.19.0 |
| file://../sm-gpu | inferenceServerEnhancedRecipe1(sm-gpu) | ~3.19.0 |
| file://../sm-gpu | inferenceServerEnhancedRecipe2(sm-gpu) | ~3.19.0 |
| file://../sm-gpu | inferenceServerEnhancedRecipe3(sm-gpu) | ~3.19.0 |
| file://../sm-gpu | inferenceServerEnhancedRecipe4(sm-gpu) | ~3.19.0 |
| file://../sm-proxy | proxy(sm-proxy) | ~0.3.0 |
| file://../sm-resource-manager | resourceManager(sm-resource-manager) | ~1.7.0 |
| file://../sm-transcriber | transcribers(sm-transcriber) | ~0.7.0 |

## Overview

Deploy RT transcribers, inference controller and inference servers

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| flow.config.llm.llmProxy.modelGroup | string | `"vllm"` |  |
| flow.config.tts.sm.enabled | bool | `true` |  |
| flow.enabled | bool | `false` | Enable deployment of Flow service |
| flow.fullnameOverride | string | `"flow-service"` |  |
| flow.llmProxy.config | object | `{"model_list":[{"llm_params":{"model":"meta-llama/Llama-3.2-3B-Instruct","url":"http://llm:8000/v1/chat/completions"},"model_name":"vllm"}]}` | LLM proxy configuration |
| flow.llmProxy.enabled | bool | `true` | Enable deployment of LLM proxy |
| flow.llmProxy.fullnameOverride | string | `"llm-proxy"` |  |
| flow.llmProxy.isOnPrem | bool | `true` |  |
| flow.tts.enabled | bool | `true` | Enable deployment of TTS |
| flow.tts.fullnameOverride | string | `"tts"` |  |
| flow.vllm.config.model | string | `"meta-llama/Llama-3.2-3B-Instruct"` | Model to use for vLLM |
| flow.vllm.enabled | bool | `true` | Enable deployment of vLLM |
| flow.vllm.fullnameOverride | string | `"llm"` |  |
| flow.vllm.hfTokenSecret.createSecret | bool | `false` | Create secret for Hugging Face token or read from existing secret |
| flow.vllm.hfTokenSecret.secretName | string | `"vllm-secret"` | Secret name to read Hugging Face token from |
| flow.vllm.hfTokenSecret.token | string | `""` | Base64 encoded Hugging Face token |
| global.cluster | string | `"test"` | Cluster name (This is required for multi-cluster setups) |
| global.config.enabled | bool | `true` |  |
| global.flow.flowUseLocalTranscriber | bool | `true` | Connect local ASR workers from Flow workers |
| global.flow.image.registry | string | `"speechmaticspublic.azurecr.io"` | Registry to pull images from |
| global.flow.image.tag | string | `"0.27.4-1305499"` | Image tag for Flow service component |
| global.imagePullSecrets[0] | object | `{"name":"speechmatics-registry"}` | List of image pull secrets to use |
| global.licensing.createSecret | bool | `false` | Create secret for license or read from existing secret |
| global.licensing.license | string | `""` | Base64 encoded license file |
| global.licensing.secretName | string | `"speechmatics-license"` | Secret name to read license from |
| global.proxy.image.registry | string | `"speechmaticspublic.azurecr.io"` | Registry to pull images from |
| global.proxy.image.tag | string | `"2.8.8-1307675"` | Image tag for proxy component |
| global.resourceManager | object | `{"image":{"registry":"speechmaticspublic.azurecr.io","tag":"1.34.6-1307912"}}` | Common resource manager components configuration |
| global.resourceManager.image | object | `{"registry":"speechmaticspublic.azurecr.io","tag":"1.34.6-1307912"}` | Resource manager image configuration |
| global.resourceManager.image.registry | string | `"speechmaticspublic.azurecr.io"` | Registry to pull images from |
| global.resourceManager.image.tag | string | `"1.34.6-1307912"` | Version of resource manager components and sidecars (defaults to appVersion) |
| global.sessionGroups | object | `{"enabled":true,"scaling":{"enabled":false}}` | Enable deployment of all components as session groups |
| global.sessionGroups.enabled | bool | `true` | Enable deployment of components as session groups |
| global.sessionGroups.scaling.enabled | bool | `false` | Enable auto-scaling of sessiongroup components |
| global.transcriber | object | `{"image":{"registry":"speechmaticspublic.azurecr.io","tag":"13.5.0"},"languages":["en"]}` | Common transcriber/inference server configuration |
| global.transcriber.image.registry | string | `"speechmaticspublic.azurecr.io"` | Registry to pull images from |
| global.transcriber.image.tag | string | `"13.5.0"` | Image tag for both transcribers and inference server |
| global.transcriber.languages | list | `["en"]` | List of languages supported by environment |
| global.tts.image.registry | string | `"speechmaticspublic.azurecr.io"` | Registry to pull images from |
| global.tts.image.tag | string | `"1.1.0"` | Image tag for TTS component |
| inferenceServerCustom.enabled | bool | `false` | Enable deployment of inference server with custom model recipe |
| inferenceServerCustom.fullnameOverride | string | `"inference-server-custom"` |  |
| inferenceServerCustom.inferenceSidecar.enabled | bool | `true` | Enable deploying inference sidecar for inference servers |
| inferenceServerCustom.inferenceSidecar.registerFeatures.capacity | int | `480` | Total capacity of inference server in terms of model cost |
| inferenceServerCustom.inferenceSidecar.registerFeatures.customModelCosts | object | `{}` | Map to define model costs for custom recipe type |
| inferenceServerCustom.inferenceSidecar.resourceManager.configMap.enabled | bool | `true` | Enable reading resource-manager server information from configMap |
| inferenceServerCustom.tritonServer.image.repository | string | `"sm-gpu-inference-server-enhanced-recipe1"` | Repository for the inference server triton container |
| inferenceServerCustom.tritonServer.mode | string | `"rt"` | Mode to run inference servers in (rt or batch) |
| inferenceServerCustom.tritonServer.operatingPoint | string | `"enhanced"` | Operating point can be standard or enhanced or set null to support both |
| inferenceServerCustom.tritonServer.recipe | string | `"custom"` | Recipe can be standard-all, enhanced-recipe1, enhanced-recipe2, enhanced-recipe3, enhanced-recipe4 or custom |
| inferenceServerEnhancedRecipe1.enabled | bool | `true` | Enable deployment of inference server with enhanced model recipe 1 |
| inferenceServerEnhancedRecipe1.fullnameOverride | string | `"inference-server-enhanced-recipe1"` |  |
| inferenceServerEnhancedRecipe1.inferenceSidecar.enabled | bool | `true` | Enable deploying inference sidecar for inference servers |
| inferenceServerEnhancedRecipe1.inferenceSidecar.registerFeatures.additionalModelCosts | object | `{}` | Map of additional models to include under model_costs |
| inferenceServerEnhancedRecipe1.inferenceSidecar.registerFeatures.capacity | int | `480` | Total capacity of inference server in terms of model cost |
| inferenceServerEnhancedRecipe1.inferenceSidecar.registerFeatures.modelCosts.am | int | `0` | Cost of am model request |
| inferenceServerEnhancedRecipe1.inferenceSidecar.registerFeatures.modelCosts.body | int | `0` | Cost of body model request |
| inferenceServerEnhancedRecipe1.inferenceSidecar.registerFeatures.modelCosts.diar | int | `0` | Cost of diar model request |
| inferenceServerEnhancedRecipe1.inferenceSidecar.registerFeatures.modelCosts.ensemble | int | `20` | Cost of Non-English ensemble model request |
| inferenceServerEnhancedRecipe1.inferenceSidecar.registerFeatures.modelCosts.ensemble_en | int | `16` | Cost of English ensemble model request  (Recipe 1) |
| inferenceServerEnhancedRecipe1.inferenceSidecar.registerFeatures.modelCosts.lm_en | int | `8` | Cost of English lm model request (Recipe 1) |
| inferenceServerEnhancedRecipe1.inferenceSidecar.resourceManager.configMap.enabled | bool | `true` | Enable reading resource-manager server information from configMap |
| inferenceServerEnhancedRecipe1.tritonServer.image.repository | string | `"sm-gpu-inference-server-enhanced-recipe1"` | Repository for the inference server triton container |
| inferenceServerEnhancedRecipe1.tritonServer.mode | string | `"rt"` | Mode to run inference servers in (rt or batch) |
| inferenceServerEnhancedRecipe1.tritonServer.operatingPoint | string | `"enhanced"` | Operating point can be standard or enhanced or set null to support both |
| inferenceServerEnhancedRecipe1.tritonServer.recipe | string | `"enhanced-recipe1"` | Set to enhanced-recipe1 to deploy Enhanced model recipe 1 |
| inferenceServerEnhancedRecipe2.enabled | bool | `false` | Enable deployment of inference server with enhanced model recipe 2 |
| inferenceServerEnhancedRecipe2.fullnameOverride | string | `"inference-server-enhanced-recipe2"` |  |
| inferenceServerEnhancedRecipe2.inferenceSidecar.enabled | bool | `true` | Enable deploying inference sidecar for inference servers |
| inferenceServerEnhancedRecipe2.inferenceSidecar.registerFeatures.additionalModelCosts | object | `{}` | Map of additional models to include under model_costs |
| inferenceServerEnhancedRecipe2.inferenceSidecar.registerFeatures.capacity | int | `480` | Total capacity of inference server in terms of model cost |
| inferenceServerEnhancedRecipe2.inferenceSidecar.registerFeatures.modelCosts.am | int | `0` | Cost of am model request |
| inferenceServerEnhancedRecipe2.inferenceSidecar.registerFeatures.modelCosts.body | int | `0` | Cost of body model request |
| inferenceServerEnhancedRecipe2.inferenceSidecar.registerFeatures.modelCosts.diar | int | `0` | Cost of diar model request |
| inferenceServerEnhancedRecipe2.inferenceSidecar.registerFeatures.modelCosts.ensemble | int | `20` | Cost of Non-Spanish ensemble model request |
| inferenceServerEnhancedRecipe2.inferenceSidecar.registerFeatures.modelCosts.ensemble_es | int | `17` | Cost of Spanish ensemble model request  (Recipe 2) |
| inferenceServerEnhancedRecipe2.inferenceSidecar.registerFeatures.modelCosts.lm_es | int | `9` | Cost of Spanish lm model request (Recipe 2) |
| inferenceServerEnhancedRecipe2.inferenceSidecar.resourceManager.configMap.enabled | bool | `true` | Enable reading resource-manager server information from configMap |
| inferenceServerEnhancedRecipe2.tritonServer.image.repository | string | `"sm-gpu-inference-server-enhanced-recipe2"` | Repository for the inference server triton container |
| inferenceServerEnhancedRecipe2.tritonServer.mode | string | `"rt"` | Mode to run inference servers in (rt or batch) |
| inferenceServerEnhancedRecipe2.tritonServer.operatingPoint | string | `"enhanced"` | Operating point can be standard or enhanced or set null to support both |
| inferenceServerEnhancedRecipe2.tritonServer.recipe | string | `"enhanced-recipe2"` | Set to enhanced-recipe2 to deploy Enhanced model recipe 2 |
| inferenceServerEnhancedRecipe3.enabled | bool | `false` | Enable deployment of inference server with enhanced model recipe 3 |
| inferenceServerEnhancedRecipe3.fullnameOverride | string | `"inference-server-enhanced-recipe3"` |  |
| inferenceServerEnhancedRecipe3.inferenceSidecar.enabled | bool | `true` | Enable deploying inference sidecar for inference servers |
| inferenceServerEnhancedRecipe3.inferenceSidecar.registerFeatures.capacity | int | `480` | Total capacity of inference server in terms of model cost |
| inferenceServerEnhancedRecipe3.inferenceSidecar.registerFeatures.customModelCosts | object | `{}` | Map to define model costs for custom recipe type |
| inferenceServerEnhancedRecipe3.inferenceSidecar.registerFeatures.modelCosts.am | int | `0` | Cost of am model request |
| inferenceServerEnhancedRecipe3.inferenceSidecar.registerFeatures.modelCosts.body | int | `0` | Cost of body model request |
| inferenceServerEnhancedRecipe3.inferenceSidecar.registerFeatures.modelCosts.diar | int | `0` | Cost of diar model request |
| inferenceServerEnhancedRecipe3.inferenceSidecar.registerFeatures.modelCosts.ensemble | int | `20` | Cost of Non-German ensemble model request |
| inferenceServerEnhancedRecipe3.inferenceSidecar.registerFeatures.modelCosts.ensemble_de | int | `17` | Cost of German ensemble model request  (Recipe 3) |
| inferenceServerEnhancedRecipe3.inferenceSidecar.registerFeatures.modelCosts.lm_de | int | `9` | Cost of German lm model request (Recipe 3) |
| inferenceServerEnhancedRecipe3.inferenceSidecar.resourceManager.configMap.enabled | bool | `true` | Enable reading resource-manager server information from configMap |
| inferenceServerEnhancedRecipe3.tritonServer.image.repository | string | `"sm-gpu-inference-server-enhanced-recipe3"` | Repository for the inference server triton container |
| inferenceServerEnhancedRecipe3.tritonServer.mode | string | `"rt"` | Mode to run inference servers in (rt or batch) |
| inferenceServerEnhancedRecipe3.tritonServer.operatingPoint | string | `"enhanced"` | Operating point can be standard or enhanced or set null to support both |
| inferenceServerEnhancedRecipe3.tritonServer.recipe | string | `"enhanced-recipe3"` | Set to enhanced-recipe3 to deploy Enhanced model recipe 3 |
| inferenceServerEnhancedRecipe4.enabled | bool | `false` | Enable deployment of inference server with enhanced model recipe 4 |
| inferenceServerEnhancedRecipe4.fullnameOverride | string | `"inference-server-enhanced-recipe4"` |  |
| inferenceServerEnhancedRecipe4.inferenceSidecar.enabled | bool | `true` | Enable deploying inference sidecar for inference servers |
| inferenceServerEnhancedRecipe4.inferenceSidecar.registerFeatures.additionalModelCosts | object | `{}` | Map of additional models to include under model_costs |
| inferenceServerEnhancedRecipe4.inferenceSidecar.registerFeatures.capacity | int | `480` | Total capacity of inference server in terms of model cost |
| inferenceServerEnhancedRecipe4.inferenceSidecar.registerFeatures.modelCosts.am | int | `0` | Cost of am model request |
| inferenceServerEnhancedRecipe4.inferenceSidecar.registerFeatures.modelCosts.body | int | `0` | Cost of body model request |
| inferenceServerEnhancedRecipe4.inferenceSidecar.registerFeatures.modelCosts.diar | int | `0` | Cost of diar model request |
| inferenceServerEnhancedRecipe4.inferenceSidecar.registerFeatures.modelCosts.ensemble | int | `20` | Cost of Non-French ensemble model request |
| inferenceServerEnhancedRecipe4.inferenceSidecar.registerFeatures.modelCosts.ensemble_fr | int | `17` | Cost of French ensemble model request  (Recipe 4) |
| inferenceServerEnhancedRecipe4.inferenceSidecar.registerFeatures.modelCosts.lm_fr | int | `9` | Cost of French lm model reques (Recipe 4) |
| inferenceServerEnhancedRecipe4.inferenceSidecar.resourceManager.configMap.enabled | bool | `true` | Enable reading resource-manager server information from configMap |
| inferenceServerEnhancedRecipe4.tritonServer.image.repository | string | `"sm-gpu-inference-server-enhanced-recipe4"` | Repository for the inference server triton container |
| inferenceServerEnhancedRecipe4.tritonServer.mode | string | `"rt"` | Mode to run inference servers in (rt or batch) |
| inferenceServerEnhancedRecipe4.tritonServer.operatingPoint | string | `"enhanced"` | Operating point can be standard or enhanced or set null to support both |
| inferenceServerEnhancedRecipe4.tritonServer.recipe | string | `"enhanced-recipe4"` | Set to enhanced-recipe4 to deploy Enhanced model recipe 4 |
| inferenceServerStandardAll.enabled | bool | `false` | Enable deployment of inference server with standard model recipe |
| inferenceServerStandardAll.fullnameOverride | string | `"inference-server-standard-all"` |  |
| inferenceServerStandardAll.inferenceSidecar.enabled | bool | `true` | Enable deploying inference sidecar for inference servers |
| inferenceServerStandardAll.inferenceSidecar.registerFeatures.additionalModelCosts | object | `{}` | Map of additional models to include under model_costs |
| inferenceServerStandardAll.inferenceSidecar.registerFeatures.capacity | int | `2400` | Total capacity of inference server in terms of model cost |
| inferenceServerStandardAll.inferenceSidecar.registerFeatures.modelCosts.am | int | `0` | Cost of am model request |
| inferenceServerStandardAll.inferenceSidecar.registerFeatures.modelCosts.body | int | `0` | Cost of body model request |
| inferenceServerStandardAll.inferenceSidecar.registerFeatures.modelCosts.diar | int | `0` | Cost of diar model request |
| inferenceServerStandardAll.inferenceSidecar.registerFeatures.modelCosts.ensemble | int | `20` | Cost of Non-English ensemble model request |
| inferenceServerStandardAll.inferenceSidecar.registerFeatures.modelCosts.ensemble_en | int | `16` | Cost of English ensemble model request |
| inferenceServerStandardAll.inferenceSidecar.resourceManager.configMap.enabled | bool | `true` | Enable reading resource-manager server information from configMap |
| inferenceServerStandardAll.tritonServer.image.repository | string | `"sm-gpu-inference-server-standard-all"` | Repository for the inference server triton container |
| inferenceServerStandardAll.tritonServer.mode | string | `"rt"` | Mode to run inference servers in (rt or batch) |
| inferenceServerStandardAll.tritonServer.operatingPoint | string | `"standard"` | Operating point can be standard or enhanced or set null to support both |
| inferenceServerStandardAll.tritonServer.recipe | string | `"standard-all"` | Set to standard-all to deploy Srandard model recipe |
| proxy.agentAPI.configMap.data | object | `chart will add a default agent configuration` | configMap data with one or more agent configurations |
| proxy.agentAPI.configMap.enabled | bool | `true` | Enable reading agent configuration from configMap |
| proxy.agentAPI.enabled | bool | `true` |  |
| proxy.agentAPI.useLocal | bool | `true` | Use local file system to fetch agent configuration |
| proxy.agentAPI.useRemote | bool | `false` | Use remote endpoint to fetch agent configuration |
| proxy.enabled | bool | `true` | Enable proxy service |
| proxy.events.enabled | bool | `false` | Enable sending events to eventhub |
| proxy.fullnameOverride | string | `"proxy"` |  |
| proxy.ingress.annotations."nginx.ingress.kubernetes.io/configuration-snippet" | string | `"# Adds the request ID header to the response, so the user can see it.\nmore_set_headers \"Request-Id: $req_id\";\n"` |  |
| proxy.ingress.annotations."nginx.ingress.kubernetes.io/use-regex" | string | `"true"` |  |
| proxy.ingress.enabled | bool | `true` | Add ingress |
| proxy.ingress.flow.enabled | bool | `true` | Enable Flow in ingress |
| proxy.ingress.ingressClassName | string | `"nginx"` | Ingress class to use |
| proxy.ingress.url | string | `"speechmatics.example.com"` | Ingress URL |
| proxy.proxy.config.additionalConfig | object | `{}` | Additional configuration variables for proxy |
| proxy.proxy.config.auth.enabled | bool | `false` | Enable proxy to handle authentication |
| proxy.proxy.config.customDictionaryCapture.enabled | bool | `false` | Store custom dictionaries externally |
| proxy.proxy.config.deadlines.enabled | bool | `false` | Enable session deadlines |
| proxy.proxy.config.isOnPrem | bool | `true` | Set proxy service to run in on-prem mode |
| proxy.proxy.config.quotaCaching.enabled | bool | `false` | Enable quota caching |
| proxy.proxy.config.useInsecureWebsockets | bool | `true` | Allow insecure websocket connections |
| proxy.proxy.config.workerConnectionType | string | `"local"` | Handle only local worker connection |
| proxy.proxy.copyAllHeaders | bool | `true` | Copy headers from incoming request to outgoing request |
| proxy.proxy.deployments.a | object | `{"active":true}` | List of deployments of proxy |
| proxy.proxy.deployments.a.active | bool | `true` | Enable sessions to this deployment |
| proxy.proxy.dns.defaultSrvRecords | list | `[]` | Default SRV record to use for proxy service; target should match with service name of resource manager |
| proxy.proxy.dns.enabled | bool | `false` | Enable DNS SRV lookup from external DNS source |
| proxy.resourceManager.configMap.enabled | bool | `true` | Read resource-manager server information from configMap |
| proxy.storage.enabled | bool | `false` | Enable storage of custom dictionary |
| resourceManager.enabled | bool | `true` |  |
| resourceManager.fullnameOverride | string | `"resource-manager"` |  |
| resourceManager.ingress.enabled | bool | `false` |  |
| resourceManager.metrics.workerMonitor.conditionMetrics | string | `"none"` |  |
| resourceManager.metrics.workerMonitor.enabled | bool | `false` | Enable monitoring of worker CPU and Memory usage, logging when usage exceeds thresholds |
| resourceManager.reconciliation | object | `{"enabled":true,"podSelectorConfigMap":{"enabled":true},"repopulation":{"enabled":false}}` | Enable Reconcialiation service |
| resourceManager.reconciliation.podSelectorConfigMap.enabled | bool | `true` | Read config values for pod_selector_list from configMap |
| resourceManager.reconciliation.repopulation | object | `{"enabled":false}` | Enable repopulation of sessions from database |
| resourceManager.redis.enabled | bool | `true` | Enable redis for resource-manager to manage sessions |
| resourceManager.redis.timeoutConnection | string | `"10m"` | Connection timeout for Redis |
| resourceManager.service.port | int | `8080` |  |
| resourceManager.sessionGroups.enabled | bool | `true` | Enable session groups controller |
| resourceManager.sessionGroups.startupProbe | object | `{"failureThreshold":20,"httpGet":{"path":"/healthz","port":8081},"periodSeconds":15}` | Higher startup probe time to allow Redis to start |
| resourceManager.startupProbe | object | `{"failureThreshold":50,"httpGet":{"path":"/ready","port":8080},"periodSeconds":15}` | Startup probe to allow for slow start times of Redis |
| transcribers.eats.enableUsageReporting | bool | `true` | Enable usage reporting to "usage.speechmatics.com" endpoint. |
| transcribers.enabled | bool | `true` |  |
| transcribers.fullnameOverride | string | `"rt-transcriber"` |  |
| transcribers.readinessTracker.preWarm.enabled | bool | `true` | Run a pre-warm session on start to improve startup connection times |
| transcribers.readinessTracker.preWarm.everySession | bool | `false` | Run preWarm for a pod after every session |
| transcribers.readinessTracker.preWarm.operatingPoint | string | `"enhanced"` | Operating point used for the preWarm session |
| transcribers.readinessTracker.restartAfterNSessions | int | `0` | Restart transcriber after N sessions |
| transcribers.resourceManager.configMap.enabled | bool | `true` | Read resource-manager server information from configMap |
| transcribers.sessionGroups.scaling.scaleOnCapacityLeft | int | `1` | Buffer size # of sessions to start triggering scaling |
| transcribers.transcriber.env | list | `[{"name":"SM_ON_PREM","value":"true"},{"name":"SM_WEBSOCKET_CONFIG","value":"{\n  \"autoPingTimeout\": 300\n}\n"},{"name":"SM_INFERENCE_RESPONSE_TIMEOUT_MS","value":"900000"}]` | Environment variables to add to transcriber container |
| transcribers.transcriber.maxConcurrentConnections.value | int | `2` | Number of sessions to allow per transcriber pod |
| transcribers.transcriber.mode | string | `"rt"` | Mode to run transcribers in (rt or batch) |
| transcribers.workerProxy.env | list | `[]` | Environment variables to add to worker-proxy container |

## Usage

### Prerequisites

#### Helm

Please ensure you are using a minimum of Helm version [3.16.0](https://github.com/helm/helm/releases/tag/v3.16.0)

#### Speechmatics Client

To run a test session against your deployment, you will want to install the [speechmatics-python](https://github.com/speechmatics/speechmatics-python?tab=readme-ov-file#speechmatics-python----) CLI client

#### Ingress Controller

##### Nginx

When setting up Speechmatics via an ingress controller, it is recommended to use the `ingress-nginx` ingress controller with snippet annotations enabled. You can confirm if your cluster supports nginx with Snippet annotations enabled using the following command:

```bash
# The default is false
kubectl get cm -o yaml -l app.kubernetes.io/instance=nginx | grep allow-snippet-annotations
```

If you are not already running `ingress-nginx`, follow the below steps:

1. Create an `nginx.values.yaml` file:

```yaml
controller:
  service:
    # This is needed to preserve the source IP of the client
    # See: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    externalTrafficPolicy: Local

    # This should be set to the IP address used to access services on your cluster
    loadBalancerIP: $CLUSTER_INGRESS_IP

  config:
    # This prevents nginx worker process from shutting down for 24h in case of active sessions
    worker-shutdown-timeout: 86400s

  extraArgs:
    # Needed to support annotations added by the chart ingresses
    annotations-prefix: nginx.ingress.kubernetes.io

    # This prevents nginx main process from shutting down for 24h in case of active sessions
    shutdown-grace-period: 86400
 
  # Used to prevent nginx pods being terminated for 24h while there are active sessions
  terminationGracePeriodSeconds: 86400

  # Needed to allow ingresses to add snippet annotations to add necessary headers
  allowSnippetAnnotations: true
```

2. Install the nginx chart with:

```bash
helm repo add nginx https://kubernetes.github.io/ingress-nginx
helm install nginx nginx/ingress-nginx --version 4.11.4 -f nginx.values.yaml
```

##### Another Ingress Controller

If you are running another ingress controller, when enabling ingress on the chart, you need to ensure that a `Request-Id` header is passed through. This is used to manage session usage.

In nginx, it looks like this:

```yaml
proxy:
  ingress:
    annotations:
      # Add headers to all requests coming through this ingress
      nginx.ingress.kubernetes.io/configuration-snippet: |+
        more_set_headers "Request-Id: $req_id";
```

#### GPU Drivers

The Speechmatics inference server runs Nvidia Triton Server, which requires a GPU. When running GPU nodes in K8s, you will require the Nvidia device plugin which allows containers on the cluster to access the GPUs.

Below is a list of the common cloud providers and their recommended way of deploying the Nvidia device plugin on a cluster. Alternatively, see [Nvidia Device Plugin](https://github.com/NVIDIA/k8s-device-plugin#deployment-via-helm)

| Cloud Provider | Docs                                                                                                                                                         |
|----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AWS            | https://docs.aws.amazon.com/deep-learning-containers/latest/devguide/deep-learning-containers-eks-setup.html#deep-learning-containers-eks-setup-gpu-clusters |
| Azure          | https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?tabs=add-ubuntu-gpu-node-pool#nvidia-device-plugin-installation                                      |
| GCP            | https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#installing_drivers                                                                               |

You can validate a node has allocatable GPU resources with: `kubectl get nodes -o yaml | yq .[].[].status.allocatable | grep nvidia`

#### Speechmatics License

The chart requires you to have a valid Speechmatics license, which you can obtain by speaking to `support@speechmatics.com`. You can configure the chart to create the secret for your Speechmatics license using the following values:

```yaml
global:
  licensing:
    createSecret: true
    license: $B64_ENCODED_LICENSE
```

Alternatively, you can manage the transcriber as a separate secret. By default it will look for a secret called `speechmatics-license` in the same namespace as the deployment. The secret requires a key of `license.json` which contains the license contents.

```bash
# Create a license secret
kubectl create secret generic $NAME_OF_LICENSE_SECRET --from-literal=license.json="$(cat $LICENSE_FILE)"
```

```yaml
global:
  licensing:
    secretName: $NAME_OF_LICENSE_SECRET
```

#### Image Pull Secrets

You will require image pull secrets configured on the cluster to be able to authenticate with the speechmatics public docker registry to pull containers deployed by the Helm chart. The credentials for this registry can be obtained by speaking to `support@speechmatics.com`.

```bash
kubectl create secret docker-registry speechmatics-registry \
  --docker-server=speechmaticspublic.azurecr.io \
  --docker-username=$REGISTRY_USERNAME \
  --docker-password=$REGISTRY_PASSWORD
```

### Quick Start

With the prerequisites installed, you are ready to consume the chart.

The credentials for the chart repository is the same as the docker repository:

```shell
# Add the speechmatics helm chart repo
helm registry login speechmaticspublic.azurecr.io --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD
```

The chart creates an ingress resource which is used to append the RequestID header, and listens on the URL `speechmatics.example.com`. You can update this URL with the `proxy.ingress.url` value:

```bash
# Install the chart
helm upgrade --install realtime oci://speechmaticspublic.azurecr.io/sm-charts/sm-realtime --version 0.5.7 --set proxy.ingress.url="transcribe.myrealtime.com"
```

#### Run a Session

Using the speechmatics client, you can target your realtime deployment.

```bash
# Set the URL to your RT deployment endpoint (See installation command above)
speechmatics config set --rt-url wss://transcribe.myrealtime.com

# Run a transcription session
speechmatics rt transcribe \
  --lang en \
  --operating-point enhanced \
  --ssl-mode insecure \
  example.wav
```

In the example, we are passing the `--ssl-mode insecure` flag as out-of-box the chart does not configure a TLS certificate for the ingress. For more information on adding a TLS certificate, see "TLS Ingress Configuration".

You can find more information on the Speechmatics docs regarding how to [transcribe in realtime with FFMPEG](https://docs.speechmatics.com/tutorials/using-ffmpeg) and how to [transcribe using microphone input](https://docs.speechmatics.com/tutorials/using-mic).

### Services Overview

#### STT Components

All STT components are deployed as SessionGroups, which is a CRD managed by this chart. STT is made up of the transcriber and the inference server.

Transcribers have a SessionGroup deployed per language, whereas inference servers support a collection of languages in what is referred to as recipes. If running in `standard` operating point, then all languages are available from the one SessionGroup. If running in `enhanced` operating point, you will need to specify the recipe relevant to the languages being used. There are a total of 4 recipes. For more information on the languages available in each enhanced recipe see [the Speechmatics docs](https://docs.speechmatics.com/on-prem/containers/accessing-images#enhanced-operating-point)

```yaml
## Standard OP Deployment
global:
  transcriber:
    # Inference server supports all languages
    languages: ["en", "fr"]

inferenceServerStandardAll:
  # Deploys inference server with standard operating point model
  enabled: true
```

```yaml
## Enhanced OP Recipe 1 deployment
global:
  transcriber:
    # Supported languages:   ba,be,cy,en,eo,eu,ga,mn,mr,ta,tr,ug,uk
    languages: ["en"]

inferenceServerEnhancedRecipe1:
  # Deploys inference server with enhanced operating point recipe1 model 
  enabled: true
```

```yaml
## Enhanced OP Recipe 2 deployment
global:
  transcriber:
    # Supported languages:   bg,es,et,fa,gl,hr,ia,id,lt,lv,ro,sk,sl,ur
    languages: ["es"]

inferenceServerEnhancedRecipe2:
  # Deploys inference server with enhanced operating point recipe2 model 
  enabled: true
```

```yaml
## Enhanced OP Recipe 3 deployment
global:
  transcriber:
    # Supported languages:   ca,cs,da,de,el,fi,he,hi,hu,it,ko,ms,sv,sw
    languages: ["de"]

inferenceServerEnhancedRecipe3:
  # Deploys inference server with enhanced operating point recipe3 model 
  enabled: true
```

```yaml
## Enhanced OP Recipe 4 deployment
global:
  transcriber:
    # Supported languages:   ar,bn,cmn,fr,ja,mt,no,nl,pl,pt,ru,th,vi,yue
    languages: ["fr"]

inferenceServerEnhancedRecipe4:
  # Deploys inference server with enhanced operating point recipe4 model 
  enabled: true
```

#### Resource Manager Components

Resource manager components include all non-transcription components as well as sidecars running in the transcription components. The version of these components can be globally configured so all components are updated together:

```yaml
global:
  resourceManager:
    image:
      tag: 1.2.3
```

The services include:

| Service Name                    | Description                                                                                  |
|---------------------------------|----------------------------------------------------------------------------------------------|
| resource-manager                | The main API and controller for STT sessions                                                 |
| resource-manager-metrics        | Exports Prometheus metrics for session usage/availability                                    |
| resource-manager-reconciliation | Responsible for reconciling the state of Redis if pods are killed without returning capacity |
| sessiongroups-controller        | Provisions and manages SessionGroup resources                                                |
| worker-proxy                    | Sidecar running inside transcribers to request and proxy connections to the inference server |
| readiness-tracker               | Sidecar running inside transcribers to manage connections/capacity and idle status           |
| inference-sidecar               | Sidecar running inside inference-server pods to manage connections/capacity                  |

#### Proxy Service

Proxy service is a proxy between the client and transcriber. This service allows for multi-cluster deployments as well as exporting metrics about sessions, including session count and latency.

### Session Groups + Auto-Scaling

#### Overview

SessionGroups is a custom Speechmatics CRD which is used to allocate idle transcribers/inference servers, manage scaling up and down of transcribers/inference servers, and protection of active sessions. It provides the following benefits:

- Auto-scaling up and down of sensitive websocket connections based on a buffer
- Bin-packing of sessions to run an efficient number of nodes
- Prevent sessions from being terminated by node scale down
- Rolling update of transcribers/inference servers without interrupting existing sessions
- Control over session capacity and how many connections a transcriber/inference server can accept

You can view deployed session groups and their usage with the command: `kubectl get sessiongroups`

The output will look something like:

```bash
NAME                                REPLICAS   CAPACITY   USAGE   VERSION   SPEC HASH
inference-server-enhanced-recipe1   1          360        0       2         0492bb2d21f1fa9dac851e31a48667d9
rt-transcriber-en                   1          2          0       4         ebf88debb77fe9853455ac7d5a24c6ef
```

Replicas refers to the number of pods deployed, Capacity refers to the total capacity deployed and Usage is how much of the capacity is currently used.

#### Scaling

The auto-scaling works using a buffer, so as more transcribers/inference servers get allocated connections, more idle transcribers/inference servers will scale up. Auto-scaling buffers can be configured in helm values:

```yaml
global:
  sessionGroups:
    scaling:
      # Enable auto-scaling of session groups
      enabled: true

transcribers:
  sessionGroups:
    scaling:
      # -- Minimum number of pods to deploy
      minReplicas: 3

      # -- Max number of pods to scale to
      maxReplicas: 10

      # -- Wait time before scaling down a transcriber once idle
      scaleDownDelay: 1m0s

      # -- Session capacity for when to scale up (Supports decimals)
      scaleOnCapacityLeft: 5
```

`((replicas x maxConcurrentConnections) - scaleOnCapacityLeft) = supported sessions before scaling`

Once there is less than 5 idle connections available, SessionGroups will scale up the transcribers to ensure a capacity of 5. For example, 3 replicas totals 6 total connections. Once there is more than 2 active connections, another pod will added until the available connections totals 5.

#### Session Protection

SessionGroups also protects sessions from being terminated during scale down of nodes, and rolling update. SessionGroups will manage the update process of STT components by identifying idle pods that can be updated and leaving pods with active sessions.

### Concurrency

By default, the chart is configured to allow 2 connections to each transcriber. This can be configured with the following values:

```yaml
transcribers:
  transcriber:
    maxConcurrentConnections:
      value: NUMBER_OF_CONNECTIONS
```

This value can be overridden for each language with the `transcriber.languages.overrides.maxConcurrentConnections` values:

```yaml
transcriber:
  languages:
    overrides:
      maxConcurrentConnections:
        en: NUMBER_OF_EN_CONNECTIONS
        es: NUMBER_OF_ES_CONNECTIONS
```

Changing this value could affect the resource requirements of the transcriber.

The recommended resource requests for 2 connections to each transcriber (double session workers) are the current default values:

```yaml
transcriber:
  readinessTracker:
    resources:
      requests:
        cpu: 10m
        memory: 15Mi

  workerProxy:
    resources:
      requests:
        cpu: 10m
        memory: 15Mi
```

#### Model Costs

The cost of a session for a transcriber is `1`. However, depending on the features and languages used in a session (and the configured model cost), the cost of that session to the inference server can be between `20-33`.

The capacity of an inference server determines the number of sessions that can be connected to it: `capacity/cost_per_session`.

**Recommended capacities:**

| Component                         | Capacity | Respective Session Count |
|-----------------------------------|----------|--------------------------|
| inference-server-enhanced-recipe1 | 480      | 20-24                    |
| inference-server-enhanced-recipe2 | 480      | 18-24                    |
| inference-server-enhanced-recipe3 | 480      | 18-24                    |
| inference-server-enhanced-recipe4 | 480      | 18-24                    |
| inference-server-stanard-all      | 2400     | 18-24                    |
| transcriber                       | 2        | 2                        |

By default, the chart has been configured to set the capacity to `480` for enhanced recipes and `2400` for standard-all. Model costs have been configured alongside these capacities to maintain the recommended session counts for each recipe (shown in the table above).

The model cost and capacity of an inference server can be overriden in the helm values:

```yaml
inferenceServer:
  inferenceSidecar:
    registerFeatures:
      capacity: CAPACITY
      modelCosts:
        <model_type>: MODEL_COST # e.g. ensemble: 20
```

### Usage Reporting

By default, all events will be reported to `usage.speechmatics.com`. If you are running your own usage container, you can update the configuration to point to that endpoint with these values:

```yaml
transcribers:
  eats:
    url: "USAGE_CONTAINER_URL:PORT"
```

### Production Environments

#### Infrastructure Setup

By default, no node selectors or taints/tolerations will be in place. Providing GPU drivers have been setup correctly, inference servers should always schedule on a GPU node due to their default resource requirements:

```yaml
  resources:
    limits:
      # -- GPU requirements for Triton server
      nvidia.com/gpu: "1"
```

However, this does not stop other services running on these GPU nodes. It is recommended to run the inference servers and transcribers on separate nodes, so adding a taint to the GPU nodes will ensure that the transcribers are not able to run there.

It is possible to configure node selectors and tolerations for both session groups to deploy on separate node types.

```yaml
inferenceServer:
  tritonServer:
    nodeSelector: {}
      # gpu: "true"

    # -- Tolerations for Triton server deployments
    tolerations:
      - key: "node-type"
        operator: "Equal"
        value: "gpu"
        effect: "NoSchedule"

transcribers:
  transcriber:
    tolerations:
      - key: "node-type"
        operator: "Equal"
        value: "transcriber-only"
        effect: "NoSchedule"
```

##### Recommended Node Sizes

Below are the Azure VM sizes which we recommend for running our services

| Service            | Node Type            |
|--------------------|----------------------|
| Inference Server   | Standard_NC4as_T4_v3 |
| Transcriber        | Standard_E16s_v5     |
| All other services | Standard_D*s_v5      |

#### Redis

If you are running a multi-cluster solution, there needs to be a redis deployed for each cluster.

Redis can be managed externally from the cluster, and the chart can be configured to point to this redis by setting these values. This will create a secret which stores the redis connection URL.

```yaml
resourceManager:
  externalRedis:
    enabled: true

  redis:
    enabled: false
    url: B64_ENCODED_REDIS_CONN_URL # base64 encoded

  secrets:
    redis:
      create: true
```

Alternatively, the redis connection URL secret can be created separately and the secret name can be passed to the chart. The secret value should be base64 encoded and have the key `redis_url`.

```yaml
resourceManager:
  externalRedis:
    enabled: true

  redis:
    enabled: false

secrets:
  redis:
    name: NAME_OF_REDIS_CONNECTION_SECRET
```

If you wish to keep Redis maintained by the chart, it can be configured to run in HA mode with Sentinel:

```yaml
resourceManager:
  redis:
    sentinel:
      enabled: true
   
    replicas:
      # -- In sentinel mode, this runs 2 pods. In Non-Sentinel, this will run master + 2 replicas (3 pods)
      replicaCount: 2
```

#### Service Upgrades

Real-time STT sessions leverage websockets which are sensitive to any service disruption. This is why we recommend using SessionGroups to manage transcription components, which allow for in-place transcriber and inference server updates. However, non-sessiongroup components such as proxy-service and an ingress controller will not be protected disruptions.

##### Ingress Controller Configuration

Any updates to an ingress controller could result in nginx processes restarting which will break a websocket connection. If you are using nginx, it is recommended to set the following configuration in the nginx helm chart:

```yaml
controller:
  config:
    # This prevents nginx worker process from shutting down for 24h in case of active sessions
    worker-shutdown-timeout: 86400s

  extraArgs:
    # This prevents nginx from shutting down for 24h in case of active connections
    shutdown-grace-period: 86400

  terminationGracePeriodSeconds: 86400
```

This will ensure that nginx will not restart for at least 24h. This can be configured to your preferred max session duration.

##### Proxy Service Deployments

Any restart of a proxy-service pod will also terminate a websocket connection. The proxy chart allows you to configure multiple deployments and A/B switch between them based on service labels:

```yaml
proxy:
  proxy:
    deployments:
      a:
        active: true
        image:
          tag: 1.2.3
      b:
        active: false
        image:
          tag: 1.2.4
```

The example above will deploy 2 proxy-service deployments (a and b), with active traffic being sent to `a`. Once `b` is up and running, the `active` can be switched to the `b` deployment to avoid any disruption. Traffic will eventually drain away from `a` but the pods will remain scaled up.

#### Language-Specific Configuration

##### Resources

Different transcriber languages can have different requirements to others. The chart allows you to better fine-tune the resource requirements of a language using the `transcribers.transcriber.languages.overrides` block. Each language is already configured at the recommended value when operating with 2 concurrent sessions per transcriber. If the concurrency level is changed, then the resources will need to be updated for each transcriber language.

```yaml
transcribers:
  transcriber:
    languages:
      # -- Override specific behaviour per language
      overrides:
        resources:
          ar:
            requests:
              cpu: 500m
              memory: 5Gi
          sv:
            requests:
              cpu: 200m
              memory: 3Gi
```

##### Autoscaling

Requirements for auto-scaling individual languages is also likely to be different depending on the number of languages supported and traffic demand. The buffer can be configured independently for each language under `transcribers.transcriber.languages.overrides.sessionGroupsScaling`

```yaml
transcribers:
  transcriber:
    languages:
      # -- Override specific behaviour per language
      overrides:
        sessionGroupsScaling:
          ar:
            # -- Minimum number of ar pods to run
            minReplicas: 3

            # -- Buffer to start scaling on once capacity is exceeded
            scaleOnCapacityLeft: 4
          bg:
            minReplicas: 20
            scaleOnCapacityLeft: 15
```

#### TLS Ingress Configuration

The proxy ingress can be configured to add a TLS block with the following values:

```yaml
proxy:
  proxy:
    config:
      # -- Dont allow insecure websockets connections to proxy
      useInsecureWebsockets: false
  ingress:
    url: $REALTIME_URL
    tls:
      # -- Name of the TLS secret
      secretName: my-certificate
   
    # Add any needed annotations (cert-manager example)
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt
```

### Uninstall

Speechmatics can be uninstalled with:

```bash
helm uninstall realtime
```

Depending on the configuration setup, you may also need to remove PVCs created from the redis deployment:

```bash
# Delete any left-over PVCs with `kubectl delete pvc`
kubectl get pvc | grep redis-data
```

### FAQs

*1. I can see SessionGroups in the cluster, but logs are saying there is no available transcriber*

> You can log into redis and view the registered resources with the command `keys *` - this will show what transcription components have registered their capacity with resource manager. If the pod IPs for a session group is not visible they, try restarting the readiness-tracker container or inference-sidecar container.

*2. Connection times for transcription sessions are very slow*

> When running standard, the connection times can be slow as the transcribers are configured in Enhanced operating point mode by default. You can modify "pre-warm" on the chart to initiate a standard session on startup so follow up connections are faster.
>
> The operating point for pre-warm can be changed to standard using following helm values:

```yaml
transcriber:
  readinessTracker:
    preWarm:
      operatingPoint: standard
```

*3. Sessions are being dropped after an nginx upgrade*

> Many different service updates, including proxy-service and the ingress controller, can impact active sessions. Ensure that pods for these services are not restarted while they are handling sessions.
>
> Nginx can be configured to prevent it from being restarted if there is an active session using the following helm values:

```yaml
# nginx values
controller:
  config:
    # This prevents nginx worker process from shutting down for 24h in case of active sessions
    worker-shutdown-timeout: 86400s

  extraArgs:
    # This prevents nginx from shutting down for 24h in case of active connections
    shutdown-grace-period: 86400

  # Used to prevent nginx pods being terminated for 24h while there are active sessions
  terminationGracePeriodSeconds: 86400
```
>
>For more details, see "Service Upgrades" above

*4. Installation is complaining that SessionGroups kind does not exist*

> The SessionGroup CRDs are added as part of the charts under the `crds/` directory. These will only be installed when installing with `helm install` and if the CRDs do not already exist on the cluster.
>
> If installing with `helm template | kubectl apply -f -` then the CRDs will not be included in the outputted template. Instead, the CRDs can be applied with `kubectl apply -f ./crds`.

*5. I see a lot of containers in CrashLoopBackoff*

> Resource manager components require a connection to Redis to start successfully. Ensure that redis is running and validate the `redis_url` is correct with `kubectl get cm resource-manager-config -o yaml` or `kubectl get secret REDIS_SECRET_NAME -o yaml` if you are using an External Redis.
>
> If redis is taking a long time to start, the timeout of the RM pods can be increased with the `resourceManager.redis.timeoutConnection` value. It currently defaults to 10m.
>
> You can check the logs with `kubectl logs $POD_NAME` or check the latest events with `kubectl describe pod $POD_NAME`

*6. Transcriber Pods are stuck in Init:0/1*

> By default, the chart enables `preWarm` which is used to warm up the transcriber models to allow for faster connection times. The transcriber pod init container will check that there is capacity for the preWarm session on startup, meaning if the inference servers have not yet started, the pod will continue to stay in `Init:0/1`.
>
> If the inference servers have started and it is still stuck in `Init:0/1`, then it could be an issue with the default configuration of preWarm. By default, pre-warm will attempt to warm up with `enhanced`, this can be changed with `transcriber.readinessTracker.preWarm.operatingPoint=standard`. It could also be related to the inference servers deployed in relation to the languages you are trying to run. If languages are deployed which are not supported by inference servers, then those languages will get stuck trying to get inference server capacity.
>
>This behaviour can be disabled by setting `transcriber.workerProxy.checkForCapacityOnStart=false`. Alternatively, pre-warm can be disabled with `transcriber.readinessTracker.preWarm.enabled=false`.

