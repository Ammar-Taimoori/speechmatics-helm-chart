# Flow Usage

## Prerequisites

Before proceeding with the Flow setup, ensure you have completed all `sm-realtime` chart [prerequisites](../../README.md#prerequisites).

### Speechmatics Flow Client

The easiest way to start a Flow conversation is to install and use the [speechmatics-flow](https://github.com/speechmatics/speechmatics-flow) Python client.

### GPU Drivers

The Speechmatics Text-to-Speech (TTS) server (and vLLM server if enabled) runs on GPU nodes. Follow [GPU drivers](../../README.md#gpu-drivers) section for details on Nvidia device plugin setup for GPU nodes.

### Speechmatics License

The `sm-realtime` chart requires you to have a valid Speechmatics [container license](https://docs.speechmatics.com/on-prem/containers/licensing) to enable Flow and TTS service. Ensure that your license has permissions for Flow and TTS.

Follow [Speechmatics License](../../README.md#speechmatics-license) section on steps to add the license as a secret to your deployment.

### vLLM secret and model name

By default, chart is configured to deploy a vLLM server to host a LLM model from Hugging Face.

In case vLLM deployment needs to be skipped, set the following in values:

```yaml
flow:
  vllm:
    enabled: false
```

If vLLM deployment is required then you need to either create a secret with Hugging Face token or pass the token as base64 string to secret created by chart. Along with secret, you also need to give the model name that has to be deployed in the vLLM server.

#### Hugging Face Token

By default the vLLM deployment will look for a secret called `vllm-secret` with a key `hf-token-secret` containing the base64 encoded license. If the secret does not already exist in the cluster, one can be created by adding following values:

```yaml
flow:
  vllm:
    hfTokenSecret:
      createSecret: true
      token: "$HF_BASE64_TOKEN" # base64 encoded token
```

Alternatively, you can manage secret out of the chart and only pass the secret name to use. Ensure the secret is created with `hf-token-secret` key which contains the token contents.

```bash
# Create a secret with Hugging Face token string
kubectl create secret generic $NAME_OF_VLLM_SECRET --from-literal=hf-token-secret="$HUGGING_FACE_HUB_TOKEN"
```

```yaml
flow:
  vllm:
    hfTokenSecret:
      createSecret: false
      secretName: $NAME_OF_VLLM_SECRET
```

#### LLM model name

By default the chart is configured to run with `meta-llama/Llama-3.2-3B-Instruct`

The model to download from Hugging Face and deploy in the vLLM server can be configured using the below values:

```yaml
flow:
  vllm:
    config:
      model: meta-llama/Llama-3.2-3B-Instruct
```

**Note**: Make sure your account in Hugging Face has access for the chosen model.

Refer [vLLM deployment](./vllm-deployment.md) for steps on how to modify configurations for setting up vLLM.

## Getting Started

With the prerequisites installed, you can deploy Flow using the `sm-realtime` chart by setting `flow.enabled` values to `true`.

```yaml
flow:
  enabled: true
```

```bash
# Install/upgrade the chart
helm upgrade --install realtime oci://speechmaticspublic.azurecr.io/sm-charts/sm-realtime \
  --version 0.4.0 \
  --set proxy.ingress.url="myrelease.example.com" \
  --set flow.enabled=true
```

Refer [flow.values.yaml](../examples/flow.values.yaml) example values file to enable Flow deployment using this chart.

### Start a Flow conversation

Using the [speechmatics-flow](https://github.com/speechmatics/speechmatics-flow) client, you can talk to your new Flow deployment:

```bash
speechmatics-flow \
    --url wss://myrelease.example.com/v1/flow \
    --ssl-mode insecure \
    --assistant 32f4725b-fde5-4521-a57c-e899e245d0b0:en::latest
```

In the example, we are passing the `--ssl-mode insecure` flag as out-of-box the chart does not configure a TLS certificate for the ingress. For more information on adding a TLS certificate, see ["TLS Ingress Configuration"](../../README.md#tls-ingress-configuration).

For more information on how to use Flow, refer to the [docs](https://docs.speechmatics.com/flow/introduction).

## Flow deployment administration and advanced configuration

Flow is an extension to the `sm-realtime` chart services listed under [Services Overview](../../README.md#stt-components).

The section below will explain how to configure the Flow services and tune them for your environment.

### Flow Service

Flow service component is deployed as SessionGroups custom resource similar to STT components (transcriber and inference server). Refer to [Session Groups](../../README.md#session-groups--auto-scaling) for more details.

##### Scaling

The auto-scaling works using a buffer, so as more Flow workers get allocated connections, more idle Flow workers will scale up. Auto-scaling buffers can be configured in Helm values:

```yaml
global:
  sessionGroups:
    scaling:
      # Enable auto-scaling of session groups
      enabled: true

flow:
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

Once there is less than 5 idle connections available, SessionGroups will scale up the transcribers to ensure a capacity of 5. For example, once there is more than 5 active connections another pod will added until the available connections totals 5.

By default Flow supports only 1 concurrent connection (`maxConcurrentConnections`) per pod and should not be altered. In terms of model costs for Flow, cost of a session for a Flow pod is `1`.

##### Session Protection

SessionGroups also protects sessions from being terminated during scale down of nodes, and rolling update. SessionGroups will manage the update process of Flow service component by identifying idle pods that can be updated and leaving pods with active sessions.

### Agent configuration

Refer [Agent configuration](./agent-configuration.md) for examples on how to configure Flow agents and load them in proxy service.

### Text-to-Speech (TTS) service

TTS service component is deployed as SessionGroups custom resource similar to STT components (transcriber and inference server) and Flow. Refer to [Session Groups](../../README.md#session-groups--auto-scaling) for more details.

##### Scaling

The auto-scaling works using a buffer, so as more TTS servers get allocated connections, more idle TTS servers will scale up. Auto-scaling buffers can be configured in helm values:

```yaml
global:
  sessionGroups:
    scaling:
      # Enable auto-scaling of session groups
      enabled: true

flow:
  tts:
    sessionGroups:
      scaling:
        # -- Minimum number of pods to deploy
        minReplicas: 3

        # -- Max number of pods to scale to
        maxReplicas: 10

        # -- Wait time before scaling down a transcriber once idle
        scaleDownDelay: 1m0s

        # -- Session capacity for when to scale up (Supports decimals)
        scaleOnCapacityLeft: 2
```

`((replicas x maxConcurrentConnections) - scaleOnCapacityLeft) = supported sessions before scaling`

Once there is less than 5 idle connections available, SessionGroups will scale up the transcribers to ensure a capacity of 5. For example, once there is more than 5 active connections another pod will added until the available connections totals 5.

By default the TTS server supports only 1 concurrent connection (`maxConcurrentConnections`) per pod and should not be altered. In terms of model costs for TTS server, cost of a session for a TTS pod is `1`.

Running TTS as sessiongroup gives the same kind of [session protection](#session-protection) as we get for STT components or Flow service.

### vLLM service

By default, chart is configured to deploy a vLLM server to host a LLM model from Hugging Face. This can be disabled following steps in [vLLM secret and model name](#vllm-secret-and-model-name) prerequisites section.

Refer [vLLM secret and model name](#vllm-secret-and-model-name) section on Hugging Face token secret and model name prerequisites.

When using vLLM server deployed from chart, you can configure Flow to use this vLLM for all LLM requests unless any agent is configured with `custom_llm_config` overrides. Follow steps in [LLM Proxy configuration](./llm-proxy-configuration.md) on steps for setting up Flow/LLM Proxy service to use vLLM deployment.

Refer [vLLM deployment](./vllm-deployment.md) for steps on how to modify configurations for vLLM server.

### LLM Proxy service

LLM Proxy is a configurable proxy designed to manage and route requests to multiple LLM (Large Language Model) backends. It handles backend selection, retries, utilization tracking, and health monitoring, ensuring efficient load balancing and resilience in case of backend failures or degraded performance.

Multiple instances of the same model can be grouped together as model groups and configured in Flow service to use a particular model group for LLM requests.

Refer [LLM proxy configuration](./llm-proxy-configuration.md) on steps how to setup LLM proxy service with different model groups and LLM instances such as Azure, OpenAI or vLLM.

## Production Environments

All the recommended suggestions in chart README.md [production environments section](../../README.md#production-environments) holds valid for Flow deployment as well. 

Service upgrades to TTS server and Flow workers are similar to transcriber and inference servers since they are deployed using session groups as well.

Setup GPU resource requirements for TTS and vLLM servers along with tolerations/node selector configurations similar to the one defined in [infrastructure setup](../../README.md#infrastructure-setup).

It is possible to configure node selectors and tolerations for TTS and vLLM to deploy on separate node types.

```yaml
flow:
  tts:
    nodeSelector: {}
      # gpu: "true"

    # -- Tolerations for TTS server deployments
    tolerations:
      - key: "node-type"
        operator: "Equal"
        value: "gpu"
        effect: "NoSchedule"

  vllm:
    tolerations:
      - key: "node-type"
        operator: "Equal"
        value: "vllm-only"
        effect: "NoSchedule"
```

##### Recommended Node Sizes

Below are the Azure VM sizes which we recommend for running our services

| Service      | Node Type                            |
| ------------ | ------------------------------------ |
| TTS Server   | Standard_NC4as_T4_v3                 |
| Flow workers | Standard_E16s_v5 or Standard_D16s_v5 |

Choosing a right node for vLLM server depends on the GPU and memory requirements for model to use.
