#### Important info for the Support Team

This markdown file explains two concepts when using helm to create an RT SaaS environment: tolerations and global overrides.  
These are for internal use only and should not be made public knowledge e.g. to customers.


#### Tolerations

Please use the following tolerations block in order to schedule inference servers on GPU spot nodes, so that you can successfully install the helm chart on the dev-platform cluster. This example is in the context of using inferenceServerEnhancedRecipe1:

```yaml
inferenceServerEnhancedRecipe1:
  tritonServer:
  # -- Schedule pods on spot nodes
    tolerations:
      - key: "nvidia.com/gpu"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "sku"
        operator: "Equal"
        value: "gpu"
        effect: "NoSchedule"
      - key: "kubernetes.azure.com/scalesetpriority"
        operator: "Equal"
        value: "spot"
        effect: "NoSchedule"
```


#### Global Override

The following block is an example for globally overriding the default values for the components of the environment. The purpose of this is to make it quicker and easier to change the registry from which you are pulling images from compared to editing the YAML sections dedicated to each component e.g. proxy. This defaults to the dev registry as this is for internal users e.g. Support.

```yaml
global:
  resourceManager:
    image:
      registry: speechmatics.azurecr.io
  transcriber:
    image:
      registry: speechmatics.azurecr.io
```
  