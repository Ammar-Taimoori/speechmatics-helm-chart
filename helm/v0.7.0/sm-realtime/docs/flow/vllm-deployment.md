# vLLM deployment

Choosing a right node for vLLM server depends on the GPU and memory requirements for model to use.

Configure the resource requirement and number of GPUs to use for a model using the below values:

```yaml
flow:
  vllm:
    config:
      numGPUs: 2
    
    resources:
      limits:
        nvidia.com/gpu: "2"
```

## Storage Class and Access Mode

vLLM server deployment creates a persistent volume claim (PVC) and mounts a volume into the vLLM container. This is to download the model from Hugging Face into the volume and reuse from local cache when vLLM server pod is recreated or scaled. 

Ensure the storage size, access modes and storage class to use are configured based on the type of storage class available in your kubernetes cluster. 
We recommend using storageClass that supports `ReadWriteMany` access mode so that more than one pod can access a volume to load models. Use bigger storage size when using a bigger model for your vLLM server.

An example configuration for using `azurefile` storage class with `ReadWriteMany` access mode:

```yaml
flow:
  vllm:
    storage:
      size: 20Gi
      accessModes:
        - ReadWriteMany
      storageClassName: azurefile
```

## vLLM configurations

Various configurations are supported which are converted as arguments to vLLM server. List of configs supported by chart are:

```yaml
flow:
  vllm:
    config:
        # -- Name of model to use
        model: ""

        # -- Number of GPUs to use
        numGPUs: 1

        # -- Number of tensor parallel replicas; defaults to value from numGPUs if not set
        # tensorParallelSize: 1

        # -- Model context length
        # maxModelLength: 2048

        # -- Data type for model weights and activations
        dtype: auto

        # -- Enable automatic prefix caching
        enablePrefixCaching: true

        # -- Disable logging requests
        disableLogRequests: true
```

You can configure any other additional [engine arguments for vLLM](https://docs.vllm.ai/en/latest/serving/engine_args.html) using `flow.vllm.config.additionalArgs` with argument as key.

Example config:

```yaml
flow:
  vllm:
    config:
      additionalArgs:
        gpu-memory-utilization: "0.75"
```

## vLLM instance with API key

To configure vLLM server with an API key, set the required key using the `VLLM_API_KEY` environment variable.

Use following values to set the `VLLM_API_KEY` environment variable from secret:

```yaml
flow:
  vllm:
    envFrom:
      - name: vLLM_API_KEY
        valueFrom:
          secretKeyRef:
            key: my-vllm-api-key
            name: my-secret
```

You can create the secret using

```bash
# Example to create a secret
kubectl create secret generic my-secret --from-literal=my-vllm-api-key="$(echo $VLLM_API_KEY_SECRET)"
```

## Example configuration

An example values to setup `meta-llama/Llama-3.2-3B-Instruct` model in `Standard_NV72ads_A10_v5` azure node for testing is given below:

```yaml
flow:
  vllm:
    config:
      model: meta-llama/Llama-3.2-3B-Instruct

      numGPUs: 2
      dtype: float16
      disableLogRequests: true
      enablePrefixCaching: false

      additionalArgs:
        max-num-seqs: "1"
        gpu-memory-utilization: "0.75"

    resources:
      limits:
        nvidia.com/gpu: "2"

    nodeSelector:
      type: "vllm"
    tolerations:
      - key: "node-type"
        operator: "Equal"
        value: "vllm-only"
        effect: "NoSchedule"

    storage:
      size: 50Gi
      accessModes:
        - ReadWriteMany
      storageClassName: azurefile
```
