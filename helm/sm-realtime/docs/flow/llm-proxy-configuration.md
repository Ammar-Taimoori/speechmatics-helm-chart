# LLM proxy configuration

All LLM requests from Flow service are routed via LLM proxy service unless any agent is configured with `custom_llm_config` overrides. LLM proxy service load balances between multiple instances of same model group. 

List of model group are configured using a configMap for llm proxy service. This configMap data is configurable in chart using `flow.llmproxy.config.model_list` value.

Below is an example for configuring different LLM instances in LLM proxy:

```yaml
flow:
  llmProxy:
    config:
      model_list:
        - model_name: azure-gpt-4o
          llm_params:
            url: https://example1.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-15-preview
            api_key: os.environ/AZURE_API_KEY_1
            model: gpt-4o
            tpm: 1000000
            rpm: 6000
        - model_name: azure-gpt-4o
          llm_params:
            url: https://example2.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-15-preview
            api_key: os.environ/AZURE_API_KEY_2
            model: gpt-4o
            tpm: 1000000
            rpm: 6000
        - model_name: openai-gpt-4o
          llm_params:
            url: https://api.openai.com/v1/chat/completions
            api_key: os.environ/OPENAI_API_KEY
            model: gpt-4o
            tpm: 500000
            rpm: 3000
        - model_name: vllm
          llm_params:
            url: http://llm:8000/v1/chat/completions
            model: meta-llama/Llama-3.2-3B-Instruct
```

## Explanation of different fields

- **`model_name`**: Identifier for the model. Models with the same `model_name` are considered part of the same "model group" which gets load balanced by LLM proxy service

- **`llm_params`**: Contains configuration details specific to each LLM backend:
  - **`url`**: Chat completion URL of the LLM backend.
  - **`api_key`**: Optional API key required for backend authentication. It also supports referencing environment variables in the format `os.environ/<ENV_VAR_NAME>`. Example: `os.environ/AZURE_API_KEY_1`
  - **`model`**: Name of the LLM model to be used, such as `gpt-4o`.
  - **`tpm`**: Optional **Token Per Minute** (TPM) limit for the backend. This is used to calculate utilization based on token consumption.
  - **`rpm`**: Optional **Requests Per Minute** (RPM) limit for the backend. This is used to calculate utilization based on the number of requests.

LLM proxy handles load balancing between multiple LLM instances of same model group based on latency, TPM, and RPM utilization.

`tpm` & `rpm` fields are optional under `llm_params`. If they are not specified then load balancing will be only on latency of LLM backend instances and not utilization.

Utilization based load balancing depends on LLM requests for backends responding with `X-Ratelimit-Remaining-Tokens` and `X-Ratelimit-Remaining-Requests`. 
When both `tpm` and `rpm` are set LLM proxy prioritizes **TPM (Tokens Per Minute)** for utilization calculation.

## Using secrets for api_key

It is recommended to not give API key information as plain text in values but rather use a environment variable reference in `os.environ/<API_KEY_ENV_VAR_NAME>` format. You can mount the API key as environment variable to LLM proxy using either a secret managed outside this chart or by this chart.

Use following values to pass the API key as secret to LLM proxy pods:

```yaml
flow:
  llmProxy:
    envFrom:
      - name: OPENAI_API_KEY
        valueFrom:
          secretKeyRef:
            key: my-openai-api-key
            name: my-secret

    config:
      model_list:
        - model_name: openai-gpt-4o
          llm_params:
            url: https://api.openai.com/v1/chat/completions
            api_key: os.environ/OPENAI_API_KEY
            model: gpt-4o
            tpm: 500000
            rpm: 3000
```

You can create the secret using

```bash
# Example to create a secret
kubectl create secret generic my-secret --from-literal=my-openai-api-key="$(echo $OPENAI_API_KEY_SECRET)"
```

Or if you want to use a secret already created by this chart pass a base64 string in below values:

```yaml
flow:
  llmProxy:
    secrets:
      data:
        openai-api-key: BASE64_API_KEY_STRING

    envFrom:
      - name: OPENAI_API_KEY
        valueFrom:
          secretKeyRef:
            key: openai-api-key
            name: llm-proxy

    config:
      model_list:
        - model_name: openai-gpt-4o
          llm_params:
            url: https://api.openai.com/v1/chat/completions
            api_key: os.environ/OPENAI_API_KEY
            model: gpt-4o
            tpm: 500000
            rpm: 3000
```

## Configuring model group for Flow Service

You can select a specific model from one of the model name ("model group") defined in LLM proxy config to use in Flow by explicitly setting the `flow.config.llm.llmProxy.modelGroup` value:

```yaml
flow:
  config:
    llm:
      llmProxy:
        modelGroup: vllm
```

A detailed values for configuring vLLM deployment and using that as a default model group for all agents is given below:

```yaml
flow:
  vllm:
    enabled: true
    config:
      model: meta-llama/Llama-3.2-3B-Instruct
    service:
      serviceName: llm
      port: 8000

  llmProxy:
    config:
      model_list:
        - model_name: vllm
          llm_params:
            url: http://llm:8000/v1/chat/completions
            model: meta-llama/Llama-3.2-3B-Instruct

  config:
    llm:
      llmProxy:
        modelGroup: vllm
```

You can change the service name and port using `flow.vllm.service.serviceName` and `flow.vllm.service.port` respectively. `api_base` for the vllm model group needs to be updated accordingly. Include `api_key` under `llm_params` if vLLM server is deployed using `VLLM_API_KEY` environment variable as described in [vLLM instance with API key](./vllm-deployment.md#vllm-instance-with-api-key).

## FAQs

*1. LLM proxy configuration updates to configMap are not reflected inside llm proxy container*

> Currently we are using LLM proxy configuration from configMap as environment variable and loading its content during container startup. Hot reload of the configuration is not yet supported. We recommend using reloader service, deployment rollout restart or forcing a spec update of LLM proxy service to ensure configMap updates are correctly applied.

>
> Example using a label patch:
>
> kubectl patch sg llm-proxy --type='merge' -p '{"spec":{"template":{"metadata":{"labels":{"foo":"bar"}}}}}'
