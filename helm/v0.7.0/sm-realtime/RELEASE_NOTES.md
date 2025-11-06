## 0.7.0

### Notable Changes

- Helm chart now uses pre-warm from transcriber instead of readiness tracker container for STT workers
  - Chart is configured to use `enhanced` operating point by default
- Default values are configured to use `bitnamilegacy` repository instead of `bitnami` for redis images

### Upgrading

Before upgrading to `0.7.0` version, update the following:

1. When using `standard` operating point only for STT; update values file to configure `standard` operating point to pre-warm using `transcribers.transcriber.preWarm.operatingPoint=standard` instead of `transcribers.readinessTracker.preWarm.operatingPoint=standard` used in `<0.7.0` version

    ```bash
    transcribers:
      transcriber:
        preWarm:
          # -- Run a pre-warm session on start to improve connection time for initial sessions
          enabled: true
          # -- Comma separated list of operating point to preWarm; possible values are enhanced and standard
          operatingPoint: standard
    ```

2. Update sessiongroups CRD available in `sm-realtime/crds/sessiongroups.yaml` chart path as there is a limitation on CRD upgrade when using helm install or upgrade command. Run the below command to upgrade CRD unless it is managed differently:

    ```bash
    kubectl replace -f sm-realtime/crds/sessiongroups.yaml
    ```
