---
copyright:
  years: 2018, 2021
lastupdated: "2021-05-24"

keywords: enclave manager, container, convert, private registry, credentials, permissions, error, docker, support, cert manager, tokens, sgx, authentication, intel, fortanix, runtime encryption, memory protection, data in use,

subcollection: data-shield

content-type: troubleshoot
---

{:codeblock: .codeblock}
{:screen: .screen}
{:download: .download}
{:external: target="_blank" .external}
{:faq: data-hd-content-type='faq'}
{:gif: data-image-type='gif'}
{:important: .important}
{:note: .note}
{:pre: .pre}
{:tip: .tip}
{:preview: .preview}
{:deprecated: .deprecated}
{:beta: .beta}
{:term: .term}
{:shortdesc: .shortdesc}
{:script: data-hd-video='script'}
{:support: data-reuse='support'}
{:table: .aria-labeledby="caption"}
{:troubleshoot: data-hd-content-type='troubleshoot'}
{:help: data-hd-content-type='help'}
{:tsCauses: .tsCauses}
{:tsResolve: .tsResolve}
{:tsSymptoms: .tsSymptoms}
{:java: .ph data-hd-programlang='java'}
{:javascript: .ph data-hd-programlang='javascript'}
{:swift: .ph data-hd-programlang='swift'}
{:curl: .ph data-hd-programlang='curl'}
{:video: .video}
{:step: data-tutorial-type='step'}
{:tutorial: data-hd-content-type='tutorial'}


# Why can't I convert my container?
{: #ts-converter}
{: troubleshoot}

You attempt to convert your container and you encounter a problem.
{:shortdesc}

## Error: Container converter forbidden
{: #ts-converter-forbidden-error}

You attempt to run the container converter and receive an error: `Forbidden`.
{: tsSymptoms}

You might not be able to access the converter if your IAM or Bearer token is missing or expired.
{: tsCauses}

To resolve the issue, verify that you are using either an IBM IAM OAuth token or an Enclave Manager authentication token in the header of your request. The tokens would take the following form:
{: tsResolve}

* IAM: `Authentication: Basic <IBM_IAM_Token>`
* Enclave Manager: `Authentication: Bearer <EM_Token>`

If your token is present, verify that it is still valid and run the request again.



## The container converter is unable to connect to a private Docker registry
{: #ts-converter-unable-connect-registry}

You attempt to run the container converter on an image from a private Docker registry and the converter is unable to connect.
{: tsSymptoms}

Your private registry credentials might not be configured correctly. 
{: tsCauses}

To resolve the issue, you can follow these steps:
{: tsResolve}

1. Verify that your private registry credentials were previously configured. If not, configure them now.
2. Run the following command to dump your Docker registry credentials. If necessary, you can change the secret name.

  ```
  kubectl get secret -oyaml converter-docker-config
  ```
  {: codeblock}

3. Use a Base64 decoder to decode the secret content of `.dockerconfigjson` and verify that it is correct.



## Unable to mount AESM-socket or SGX devices
{: #ts-problem-mounting-device}

You encounter issues when you try to mount Data Shield containers on volumes `/var/run/aesmd/aesm.socket` or `/dev/isgx`.
{: tsSymptoms}

Mounting can fail due to issues with the configuration of the host.
{: tsCauses}

To resolve the issue, verify both:
{: tsResolve}

* That `/var/run/aesmd/aesm.socket` is not a directory on the host. If it is, delete the file, uninstall the Data Shield software, and perform the installation steps again. 
* That SGX is enabled in BIOS of the host machines. If it is not enabled, contact IBM support.

