---
copyright:
  years: 2018, 2020
lastupdated: "2020-12-14"

keywords: getting started tutorial, getting started, Data Shield, confidential computing, data protection, data in use, helm chart, cluster, container, role binding, bare metal, image, tiller, sample app, runtime encryption, cpu, memory,

subcollection: data-shield

content-type: tutorial

account-plan: lite
services: containers, registry, openshift
completion-time: 30m

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



# Getting started {{site.data.keyword.datashield_short}}
{: #getting-started}
{: toc-content-type="tutorial"}
{: toc-services="containers, registry, openshift"}
{: toc-completion-time="30m"}

With {{site.data.keyword.datashield_full}}, powered by Fortanix®, you can protect the data in your container workloads that run on {{site.data.keyword.containershort_notm}} or OpenShift while your data is in use.
{: shortdesc}


Already have an app that's configured to use Intel SGX? Check out information about using Intel SGX on [Kubernetes](/docs/containers?topic=containers-add_workers#install-sgx), [OpenShift](/docs/openshift?topic=openshift-add_workers#install-sgx), or directly with [bare metal](/docs/bare-metal?topic=bare-metal-bm-server-provision-sgx).
{: tip}


![Getting started steps.](images/getting-started.png){: caption="Figure 1. Getting started with {{site.data.keyword.datashield_short}}" caption-side="bottom"}

You can be up and running with {{site.data.keyword.datashield_short}} in just three steps. To get started with the first step, complete the getting started tutorial. If you've already installed {{site.data.keyword.datashield_short}} on your cluster, and you're ready to convert or deploy, skip to **Next steps**. For more information about {{site.data.keyword.datashield_short}}, and what it means to protect your data in use, see [about the service](/docs/data-shield?topic=data-shield-about).



## Before you begin
{: #gs-before}

Before you get started, ensure that you have the following CLIs and plug-ins downloaded.

* [{{site.data.keyword.cloud_notm}} CLI](/docs/cli?topic=cli-install-ibmcloud-cli)
* [{{site.data.keyword.containershort}} and {{site.data.keyword.registryshort_notm}} plug-ins](/docs/cli?topic=cli-plug-ins)
* [Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl/){: external}
* [Docker](https://docs.docker.com/install/){: external}


## Prepare your cluster
{: gs-prepare-cluster}
{: step}

To work with {{site.data.keyword.datashield_short}}, you must have an SGX enabled bare metal cluster. Depending on whether you're working with Kubernetes or OpenShift, the machine type differs. Be sure that you have the correct machine type by reviewing the following table. For help with configuring your {{site.data.keyword.containershort_notm}} environment, check out [creating Kubernetes clusters](/docs/containers?topic=containers-cs_cluster_tutorial#cs_cluster_tutorial_lesson1) or [creating OpenShift clusters](/docs/openshift?topic=openshift-openshift_tutorial).

<table>
  <tr>
    <th>Type of cluster</th>
    <th>Available machine types</th>
  </tr>
  <tr>
    <td>{{site.data.keyword.containershort}}</td>
    <td><code>me4c.4x32</code> and <code>me4c.4x32.1.9tb.ssd</code></br>To see the options, you must filter to the <b>Ubuntu 16</b> operating system.</td>
  </tr>
  <tr>
    <td>{{site.data.keyword.openshiftshort}}</td>
    <td><code>me4c.4x32</code> and <code>me4c.4x32.1.9tb.ssd</code></td>
  </tr>
</table>

When you have a running cluster, you can start obtaining the information that you need to install the service. Be sure to save the information that you obtain so that you can use during installation.

1. Log in to the {{site.data.keyword.cloud_notm}} CLI by running the following command and then following the prompts. If you have a federated ID, append the `--sso` option to the end of the command.

  ```
  ibmcloud login
  ```
  {: codeblock}

2. Set the context for your cluster.

  ```
  ibmcloud ks cluster config --cluster <cluster_name_or_ID>
  ```
  {: codeblock}

3. If you don't know the email that is associated with the administrator or the account ID, run the following command. Make a note of this information.

  ```
  ibmcloud account show
  ```
  {: codeblock}

4. Get the Ingress subdomain for your cluster. Make a note of this information.

  ```
  ibmcloud ks cluster get --cluster <cluster_name>
  ```
  {: codeblock}


## Configure credentials
{: #gs-convert}
{: step}

Before you can run applications in an Enclave, your container image must be converted. To prepare your image for conversion, create a service ID and give it permissions to work with the container converter.

Not working with IBM Cloud Container Registry? Learn how to [configure credentials for other registries](/docs/data-shield?topic=data-shield-convert#configure-other-registry).
{: tip}


1. Create a service ID and a service ID API key for the {{site.data.keyword.datashield_short}} container converter.

  ```
  ibmcloud iam service-id-create data-shield-container-converter -d '{{site.data.keyword.datashield_short}} Container Converter'
  ```
  {: codeblock}

2. Create an API key for the container converter.

  ```
  ibmcloud iam service-api-key-create '{{site.data.keyword.datashield_short}} Container Converter' data-shield-container-converter
  ```
  {: codeblock}

3. Grant the service ID permission to access your container registry.

  ```
  ibmcloud iam service-policy-create data-shield-container-converter --roles Reader,Writer --service-name container-registry
  ```
  {: codeblock}

4. Create a Kubernetes secret to be used for future conversions. Replace the `<api key>` variable, and then run the following command. If you don't have `openssl`, you can use any command-line base64 encoder with appropriate options. Be sure that there are not new lines in the middle or at the end of the encoded string.

  ```
  (echo -n '{"auths":{"<region>.icr.io":{"auth":"'; echo -n 'iamapikey:<api key>' | openssl base64 -A;  echo '"}}}') | kubectl create secret generic converter-docker-config --from-file=.dockerconfigjson=/dev/stdin
  ```
  {: codeblock}


## Install Helm and `cert manager`
{: #gs-helm}
{: step}

To work with {{site.data.keyword.datashield_short}}, you can use Helm version 2 or 3 to install the service. The following steps explain how to set up Helm if Tiller is not installed with a service account. If you already have Tiller installed, check out the [Kubernetes Service docs](/docs/containers?topic=containers-helm) for more information.


### Installing Helm v3
{: #install-helm-v3}

1. Install [version 3](https://helm.sh/docs/intro/install/){: external} of the CLI.

2. Add the `iks-charts` repo to your instance of Helm.

  ```
  helm repo add iks-charts https://icr.io/helm/iks-charts
  ```
  {: codeblock}

### Installing Helm v2
{: #gs-helm-v2}

If you're using version 2, you might want to configure Helm to use `--tls` mode. For help with enabling TLS check out the [Helm repository](https://v2.helm.sh/docs/tiller_ssl/#using-ssl-between-helm-and-tiller){: external}. If you enable TLS, be sure to append `--tls` to every Helm command that you run.

1. Download [version 2](https://github.com/helm/helm/releases/tag/v2.16.6){: external}.

2. Add the `iks-charts` repo to your instance of Helm.

  ```
  helm repo add iks-charts https://icr.io/helm/iks-charts
  ```
  {: codeblock}

3. Create a Kubernetes service account and cluster role binding for Tiller in the `kube-system` namespace of your cluster.

  ```
  kubectl create serviceaccount tiller -n kube-system
  ```
  {: codeblock}

  ```
  kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller -n kube-system
  ```
  {: codeblock}

4. Verify that the Tiller service account is created.

  ```
  kubectl get serviceaccount -n kube-system tiller
  ```
  {: codeblock}

5. Initialize the Helm CLI and install Tiller in your cluster with the service account that you created.

  ```
  helm init --service-account tiller
  ```
  {: codeblock}



### Installing `cert manager`
{: #install-cert}

{{site.data.keyword.datashield_short}} uses open source [`cert manager`](https://docs.cert-manager.io/en/latest/){: external} to set up TLS certificates for internal communication between {{site.data.keyword.datashield_short}} services.

1. Create the resource in your cluster.

  ```
  kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.10.1/deploy/manifests/00-crds.yaml
  ```
  {: codeblock}

2. Create the namespace and add a label.

  ```
  kubectl create namespace cert-manager
  kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
  ```
  {: codeblock}

3. Add the `jetstack` repo.

  ```
  helm repo add jetstack https://charts.jetstack.io
  ```
  {: codeblock}

4. Install `cert-manager`.

  * If you're using Helm v2, run the following command.

    ```
    helm repo update && helm install --name cert-manager jetstack/cert-manager --namespace cert-manager --version v0.10.1 --set extraArgs[0]="--enable-certificate-owner-ref=true" --set webhook.enabled=false
    ```
    {: codeblock}


  * If you're using Helm v3, run the following command.

    ```
    helm repo update && helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.10.1 --set extraArgs[0]="--enable-certificate-owner-ref=true" --set webhook.enabled=false
    ```
    {: codeblock}


## Install {{site.data.keyword.datashield_short}}
{: #gs-install}
{: support}
{: step}

Now that you've installed the prerequisites and created and configured your secrets, you're ready to install the service. You can use the provided Helm chart to install {{site.data.keyword.datashield_short}} on your SGX-enabled bare metal cluster.

The Helm chart installs the following components:

*	The supporting software for SGX.
*	The {{site.data.keyword.datashield_short}} Enclave Manager.
*	The container conversion service, which allows containerized applications to run in the {{site.data.keyword.datashield_short}} environment.

### Installing with Helm v3
{: #gs-install-helm3}

To install IBM Cloud Data Shield by using version 3 of Helm, run the following command.

```
helm install <chart-name> iks-charts/ibmcloud-data-shield --set enclaveos-chart.Manager.AdminEmail=<admin email> --set enclaveos-chart.Manager.AdminName=<admin name> --set enclaveos-chart.Manager.AdminIBMAccountId=<hex account ID> --set global.IngressDomain=<your cluster's ingress domain> --set converter-chart.Converter.DockerConfigSecret=converter-docker-config
```
{: codeblock}

<table>
  <caption>Table 1. Installation options</caption>
  <tr>
    <th>Command</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>--set global.OpenShiftEnabled=true</code></td>
    <td>Optional: If you are working with an OpenShift cluster, be sure to append the OpenShift tag to your installation command.</td>
  </tr>
      <tr>
    <td><code>--set Manager.FailOnGroupOutOfDate=true</code></td>
    <td>Optional: By default, node enrollment and the issuing of application certificates succeed. If you want the operations to fail if your platform microcode is out of date, append the flag to your install command. You are alerted in your dashboard when your service code is out of date. Note: It is not possible to change this option on existing clusters.</td>
  </tr>
  <tr>
    <td><code>--set enclaveos-chart.Ias.Mode=IAS_API_KEY</code></td>
    <td>Optional: You can use your own IAS API key. To do so, you must first obtain a linkable subscription for the Intel SGX Attestation Service. Then, generate a secret in your cluster by running the following command: <code>kubectl create secret generic ias-api-key --from-literal=env=&lt;TEST/PROD&gt; --from-literal=spid=&lt;spid&gt; --from-literal=api-key=&lt;apikey&gt;</code>. Note: By default, IAS requests are made through a proxy service.</td>
  </tr>
  <tr>
    <td><code>--set global.ServiceReplicas=&lt;replica-count&gt;</code></td>
    <td>Optional: Since as of 01 December 2020, the custom IBM Cloud Kubernetes Service Ingress image is deprecated, for IBM Kubernetes clusters created after Dec 1st 2020, set the custom IBM Ingress image to `false`</td>
  </tr>
  <tr>
    <td><code>--set global.UsingCustomIBMIngressImage=false</code></td>
    <td>Optional: If you're working with multi-node clusters, you can specify the replica count by appending the service replicas tag to your install command. <strong>Note</strong>: Your maximum replica count must be fewer than or equal to the number of nodes that exist in your cluster.</td>
  </tr>
</table>

You can verify the installation and monitor the startup of your components by running `kubectl get pods`.
{: note}

### Installing with Helm v2
{: #gs-install-helm2}

To install IBM Cloud Data Shield by using version 2 of Helm, run the following command.

```
helm install iks-charts/ibmcloud-data-shield --set enclaveos-chart.Manager.AdminEmail=<admin email> --set enclaveos-chart.Manager.AdminName=<admin name> --set enclaveos-chart.Manager.AdminIBMAccountId=<hex account ID> --set global.IngressDomain=<your cluster's ingress domain> --set converter-chart.Converter.DockerConfigSecret=converter-docker-config
```
{: codeblock}

<table>
  <caption>Table 1. Installation options</caption>
  <tr>
    <th>Command</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>--set global.OpenShiftEnabled=true</code></td>
    <td>Optional: If you are working with an OpenShift cluster, be sure to append the OpenShift tag to your installation command.</td>
  </tr>
      <tr>
    <td><code>--set Manager.FailOnGroupOutOfDate=true</code></td>
    <td>Optional: By default, node enrollment and the issuing of application certificates succeed. If you want the operations to fail if your platform microcode is out of date, append the flag to your install command. You are alerted in your dashboard when your service code is out of date. Note: It is not possible to change this option on existing clusters.</td>
  </tr>
  <tr>
    <td><code>--set enclaveos-chart.Ias.Mode=IAS_API_KEY</code></td>
    <td>Optional: You can use your own IAS API key. To do so, you must first obtain a linkable subscription for the Intel SGX Attestation Service. Then, generate a secret in your cluster by running the following command: <code>kubectl create secret generic ias-api-key --from-literal=env=&lt;TEST/PROD&gt; --from-literal=spid=&lt;spid&gt; --from-literal=api-key=&lt;apikey&gt;</code>. <strong>Note</strong>: By default, IAS requests are made through a proxy service.</td>
  </tr>
  <tr>
    <td><code>--set global.ServiceReplicas=&lt;replica-count&gt;</code></td>
    <td>Optional: If you're working with multi-node clusters, you can specify the replica count by appending the service replicas tag to your install command. <strong>Note</strong>: Your maximum replica count must be fewer than or equal to the number of nodes that exist in your cluster.</td>
  </tr>
</table>

You can verify the installation and monitor the startup of your components by running `kubectl get pods`.
{: note}


## Next steps
{: #gs-next}

Now that the service is installed on your cluster, you can start protecting your data! You can choose to work with the [Enclave Manager UI](/docs/data-shield?topic=data-shield-enclave-manager), or you can choose to use the APIs to [convert](/docs/data-shield?topic=data-shield-convert#converting-images) and [deploy](/docs/data-shield?topic=data-shield-deploying) your applications.

If you don't have your own image to deploy, try deploying one of the prepackaged {{site.data.keyword.datashield_short}} images or sample apps:

* [Sample apps](https://github.com/ibm-cloud-security/data-shield-reference-apps){: external}
* [Examples GitHub repo](https://github.com/fortanix/data-shield-examples/tree/master/ewallet){: external}
* Container Registry: [Barbican image](/docs/Registry?topic=RegistryImages-datashield-barbican_starter#datashield-barbican_starter), [MariaDB image](/docs/Registry?topic=RegistryImages-datashield-mariadb_starter#datashield-mariadb_starter), [NGINX image](/docs/Registry?topic=RegistryImages-datashield-nginx_starter#datashield-nginx_starter), or [Vault image](/docs/Registry?topic=RegistryImages-datashield-vault_starter#datashield-vault_starter).
