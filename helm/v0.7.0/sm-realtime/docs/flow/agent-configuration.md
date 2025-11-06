# Agent configuration

Create agents for Flow and mount them into the proxy service container as JSON files. You can either use configMap option (supported by this chart) or additional volume/volume mounts option to mount the JSON files into proxy service container.

Local directory path to use in Proxy container can be set using `proxy.agentAPI.localPath` value.

```yaml
proxy:
  agentAPI:
    useLocal: true
    localPath: /config/agents
```

An example JSON schema for configuring agents using local file is given below:

```json
{
  "agent_id": "32f4725b-fde5-4521-a57c-e899e245d0b0",
  "name": "Jean",
  "version": "latest",
  "tts_config": {
    "preset": "SpeechmaticsTTS:american-female"
  },
  "asr_config": {
    "language": "en",
    "additional_vocab": [
        {
            "content": "Jean",
            "sounds_like": [
                "Gene"
            ]
        }
    ]
  },
  "custom_llm_config": [
    {
      "url": "https://api.openai.com/v1/chat/completions",
      "model": "gpt-4o-2024-08-06",
      "api_key": "**** api_key_here *****",
      "headers": {
          "Content-Type": "application/json"
      }
    }
  ],
  "instructions": {
    "prompt": "**{persona}**.\n\n# Style of responses:\n{style}\n{context}\n",
    "default_template_variables": {
      "persona": "You are an American female called Jean",
      "style": "Be polite and always mirror the user's tone of voice and seriousness.",
      "context": "Create an engaging and natural conversation with the user."
    },
    "first_message": "Hello, how can I help?",
    "agent_speaks_first": true
  }
}
```

| Parameter         | Description                                                                        |
| ----------------- | ---------------------------------------------------------------------------------- |
| agent_id          | UUID (v4) for agent; also used as filename for agents                              |
| name              | Name of the agent                                                                  |
| asr_config        | Map of Speech-To-Text (ASR) parameters; refer [below](asr_config)                  |
| tts_config        | Map of Text-to-Speech (TTS) parameters; refer [below](tts_config)                  |
| custom_llm_config | Optional List of Map of LLM override parameters refer [below](custom_llm_config )  |
| instructions      | Map of instructions to be set in LLM; refer [below](instructions)                  |
| version           | Version string (random string/SemVer format) or "latest" to identify agent version |

**NOTE:** Agents JSON file should be mounted into the Flow containers in `<agent_id>_<version>.json` format.

###### asr_config

| Parameter        | Description                                                                            |
| ---------------- | -------------------------------------------------------------------------------------- |
| language         | Language to use for agent                                                              |
| domain           | Optional domain string supported for the language                                      |
| additional_vocab | List of `content` and `sounds_like` (optional) map for adding custom dictionary in ASR |

###### tts_config

| Parameter | Description                                                                      |
| --------- | -------------------------------------------------------------------------------- |
| preset    | `provider:voice_id` string to identify which provider and voice to use for agent |

List of supported voices are:

| TTS preset                      | Description     |
| ------------------------------- | --------------- |
| SpeechmaticsTTS:american-female | American Female |
| SpeechmaticsTTS:american-male   | American Male   |
| SpeechmaticsTTS:french-female   | French Female   |
| SpeechmaticsTTS:spanish-female  | Spanish Female  |

###### instructions

| Parameter                  | Description                                                                                                                                 |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| prompt                     | Instructions to include in LLM system prompt when setting up the agent                                                                      |
| default_template_variables | Optional map of template variable (`persona`, `style` and `context`) defaults to replace in prompt string                                   |
| agent_speaks_first         | Boolean to identify if agent should start conversation                                                                                      |
| first_message              | Message for TTS to speak when `agent_speaks_first` is set to `true`. If no `first_message` is set then a default hello message is triggered |

###### custom_llm_config

| Parameter | Description                                     |
| --------- | ----------------------------------------------- |
| url       | Chat completion URL of the LLM instance         |
| model     | Model name to use for LLM requests              |
| api_key   | Optional API key for LLM instance               |
| headers   | Optional map of headers to pass to LLM instance |

## Agents using configMap

To enable configMap to mount agent file set `proxy.agentAPI.configMap.enabled` to `true`.

Keys for the configMap data should be filename for agent in `<agent_id>_<version>.json` format.
You can either configure the configMap values for agent as raw JSON string or in yaml format (which will get converted as JSON by chart).

Below are examples on how to set agents using configMap:

```yaml
proxy:
  agentAPI:
    useLocal: true

    configMap:
      enabled: true
      data:
        32f4725b-fde5-4521-a57c-e899e245d0b0_latest.json: |
          {
            "agent_id": "32f4725b-fde5-4521-a57c-e899e245d0b0",
            "name": "Jean",
            "version": "latest",
            "tts_config": {
              "preset": "SpeechmaticsTTS:american-female"
            },
            "asr_config": {
              "language": "en",
              "additional_vocab": [
                  {
                      "content": "Jean",
                      "sounds_like": [
                          "Gene"
                      ]
                  }
              ]
            },
            "custom_llm_config": [
              {
                "url": "https://api.openai.com/v1/chat/completions",
                "model": "gpt-4o-2024-08-06",
                "api_key": "**** api_key_here *****",
                "headers": {
                  "Content-Type": "application/json"
                }
              }
            ],
            "instructions": {
              "prompt": "**{persona}**.\n\n# Style of responses:\n{style}\n{context}\n",
              "default_template_variables": {
                "persona": "You are an American female called Jean",
                "style": "Be polite and always mirror the user's tone of voice and seriousness.",
                "context": "Create an engaging and natural conversation with the user."
              },
              "first_message": "Hello, how can I help?",
              "agent_speaks_first": true
            }
          }

        32f4725b-fde5-4521-a57c-e899e245d0b0_v1.json:
          agent_id: 32f4725b-fde5-4521-a57c-e899e245d0b0
          name: Scott
          version: v1
          tts_config:
            preset: SpeechmaticsTTS:american-male
          asr_config:
            language: en
            additional_vocab:
            - content: Scott
              sounds_like:
              - Scot
          instructions:
            prompt: "**{persona}**.\n\n# Style of responses:\n{style}\n{context}\n"
            default_template_variables:
              persona: You are an American male called Scott
              style: Be polite and always mirror the user's tone of voice and seriousness.
              context: Create an engaging and natural conversation with the user.
            first_message: Hello, how can I help?
            agent_speaks_first: true
```

Note: Agent JSON files are by mounted in path configured in `proxy.agentAPI.localPath` which defaults to `/config/agents`

## Agents using volume/volume mounts

Agents can be mounted into the Flow service container from different persistent volumes if needed instead of configMap.
You can use volumes and volumeMounts option to mount a volume in Flow container.

An example using hostPath given below:

```yaml
proxy:
  agentAPI:
    useLocal: true
    localPath: path-from-volume

    configMap:
      enabled: false
  proxy:
    additionalVolumeMounts:
      - name: agents
        path: path-from-volume

additionalVolumes:
    - name: agents
      hostPath: /flow-agents
```

**NOTE:** It is important to configure the path in `proxy.additionalVolumeMounts` same as the value set in `proxy.agentAPI.localPath` (which defaults to `/config/agents`)

Use configMap approach only if the agent configuration does not have any sensitive information such as LLM API keys or other critical information. Use secrets or other persistent volumes as alternative to configMap.

## Using Agent ID in API/Flow Client

Agent ID (template_id) for [StartConversation](https://docs.speechmatics.com/flow-api-ref#startconversation) message of the API should be set in `<agent_id(uuid)>[:<version>]` format where the `agent_id(uuid)` is mandatory part.

Version part of the agent ID is optional and defaults to `latest` if not specified.
Note to configure version as latest in agent JSON's `version` field and filename if version is not explicitly passed in StartConversation `template_id` field.

Example for using different template_id format using Speechmatics Flow python client are given below:

```shell
# Start a Flow session for latest version of an agent
speechmatics-flow --url wss://myrelease.example.com/v1/flow --ssl-mode insecure --assistant 32f4725b-fde5-4521-a57c-e899e245d0b0:latest

# Start a Flow session for latest version of an agent (another method with last part ignored)
speechmatics-flow --url wss://myrelease.example.com/v1/flow --ssl-mode insecure --assistant 32f4725b-fde5-4521-a57c-e899e245d0b0

# Start a Flow session for v2 version of an agent
speechmatics-flow --url wss://myrelease.example.com/v1/flow --ssl-mode insecure --assistant 32f4725b-fde5-4521-a57c-e899e245d0b0:v2
```

## FAQs

*1. Agents detail updated in configMap/secret or downwardAPI volume are not updated inside Flow container*

> Check if you are using `subPath` for volume mounting. A container using any volume as a subPath volume mount will not receive updates.
Refer to kubernetes [volumes](https://kubernetes.io/docs/concepts/storage/volumes/) documentation for `subPath`.

*2. Can I trigger a rolling update of proxy service pods when agents configuration is updated?*

> Any rolling update of proxy service will also drop websocket connections. Proxy service rollout is not required when using volume mounts that automatically update the files in proxy service; refer to kubernetes [volumes](https://kubernetes.io/docs/concepts/storage/volumes/) documentation. 
> 
> In case rollout is required, follow procedure defined in [proxy-service-deployments](../../README.md#proxy-service-deployments) for handling proxy service rollout without any downtime (Note: image tag overrides are not necessary in this case)

