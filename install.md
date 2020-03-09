---
copyright:
  years: 2018, 2020
lastupdated: "2020-02-04"

keywords: install data shield, data in use, helm, cluster, environment variable, role binding, bare metal, tls certificates, tiller, ingress, subdomain, docker configuration, sample app, tech preivew, runtime encryption, memory, app security,

subcollection: data-shield
---

{:external: target="_blank" .external}
{:shortdesc: .shortdesc}
{:screen: .screen}
{:pre: .pre}
{:table: .aria-labeledby="caption"}
{:codeblock: .codeblock}
{:tip: .tip}
{:note: .note}
{:important: .important}
{:deprecated: .deprecated}
{:download: .download}
{:preview: .preview}

# Installing
{: #install}

You can install {{site.data.keyword.datashield_full}} on either a {{site.data.keyword.containershort_notm}} or a {{site.data.keyword.openshiftlong_notm}} cluster by using the provided Helm chart.
{: shortdesc}

**Technology preview**: With {{site.data.keyword.datashield_short}} 1.5, you can preview support for {{site.data.keyword.openshiftlong_notm}} clusters. To deploy on an {{site.data.keyword.openshiftshort}} cluster, specify `--set global.OpenShiftEnabled=true` when you [install the Helm chart](/docs/data-shield?topic=data-shield-install).

## Before you begin
{: #install-before}

Before you get started, ensure that you have the following CLIs and plug-ins downloaded.

* [{{site.data.keyword.cloud_notm}} CLI](/docs/cli/reference/ibmcloud?topic=cloud-cli-install-ibmcloud-cli)
* [{{site.data.keyword.containershort}} and {{site.data.keyword.registryshort_notm}} plug-ins](/docs/cli/reference/ibmcloud?topic=cloud-cli-plug-ins)
* [Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl/){: external}
* [Docker](https://docs.docker.com/install/){: external}
* [Helm version 2](/docs/containers?topic=containers-helm): Be sure to follow the instructions for setting up Helm in a cluster with public access.

  You might want to configure Helm to use `--tls` mode. For help with enabling TLS check out the [Helm repository](https://v2.helm.sh/docs/tiller_ssl/#using-ssl-between-helm-and-tiller){: external}. If you enable TLS, be sure to append `--tls` to every Helm command that you run.
  {: tip}


## Preparing your cluster
{: #install-prepare-cluster}

To work with {{site.data.keyword.datashield_short}}, you must have an SGX enabled cluster. Depending on whether you're working with Kubernetes or OpenShift, the machine type differs. Be sure that you have the correct machine type by reviewing the following table.

<table>
  <tr>
    <th>Type of cluster</th>
    <th>Available machine types</th>
  </tr>
  <tr>
    <td>{{site.data.keyword.containershort}}</td>
    <td><code>mb2c.4x32</code> and <code>ms2c.4x32.1.9tb.ssd</code></br>To see the options, you must filter to the <b>Ubuntu 16</b> operating system.</td>
  </tr>
  <tr>
    <td>{{site.data.keyword.openshiftshort}}</td>
    <td><code>mb3c.4x32</code> and <code>ms3c.4x32.1.9tb.ssd</code></td>
  </tr>
</table>

For help with configuring your {{site.data.keyword.containershort_notm}} environment, check out [creating Kubernetes clusters](/docs/containers?topic=containers-cs_cluster_tutorial#cs_cluster_tutorial_lesson1) or [creating OpenShift clusters](/docs/openshift?topic=openshift-openshift_tutorial).
{: tip}

When you have a running cluster, you can start obtaining the information that you need to install the service. Be sure to save the information that you obtain so that you can use during installation.

1. Log in to the {{site.data.keyword.cloud_notm}} CLI by running the following command and then following the prompts. If you have a federated ID, append the `--sso` option to the end of the command.

  ```
  ibmcloud login
  ```
  {: codeblock}

2. Set the context for your cluster.

  1. Get the command to set the environment variable and download the Kubernetes configuration files.

    ```
    ibmcloud ks cluster-config <cluster_name_or_ID>
    ```
    {: codeblock}

  2. Copy the output beginning with `export` and paste it into your console to set the `KUBECONFIG` environment variable.

3. If you don't know the email that is associated with the administrator or the account ID, run the following command. Make a note of this information.

  ```
  ibmcloud account show
  ```
  {: codeblock}

4. Get the Ingress subdomain for your cluster. Make a note of this information.

  ```
  ibmcloud ks cluster-get <cluster_name>
  ```
  {: codeblock}


## Configuring credentials
{: #install-convert}

Before you can run applications in an Enclave, your container image must be converted. To prepare your image for conversion, create a service ID and give it permissions to work with the container converter.

Not working with IBM Cloud Container Registry? Learn how to [configure credentials for other registries](/docs/data-shield?topic=data-shield-convert#configure-other-registry).
{: tip}


1. Create a service ID and a service ID API key for the {{site.data.keyword.datashield_short}} container converter.

  ```
  ibmcloud iam service-id-create data-shield-container-converter -d 'Data Shield Container Converter'
  ```
  {: codeblock}

2. Create an API key for the container converter.

  ```
  ibmcloud iam service-api-key-create 'Data Shield Container Converter' data-shield-container-converter
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



## Installing Helm and `cert manager`
{: #install-helm}

To work with {{site.data.keyword.datashield_short}}, you can use Helm version 2 to install the service. The following steps explain how to set up Helm if Tiller is not installed with a service account. If you already have Tiller installed, check out the [Kubernetes Service docs](/docs/containers?topic=containers-helm) for more information.


You might want to configure Helm to use `--tls` mode. For help with enabling TLS check out the [Helm repository](https://v2.helm.sh/docs/tiller_ssl/#using-ssl-between-helm-and-tiller){: external}. If you enable TLS, be sure to append `--tls` to every Helm command that you run.
{: tip}

1. Create a Kubernetes service account and cluster role binding for Tiller in the kube-system namespace of your cluster.

  ```
  kubectl create serviceaccount tiller -n kube-system
  ```
  {: codeblock}

  ```
  kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller -n kube-system
  ```
  {: codeblock}

2. Verify that the Tiller service account is created.

  ```
  kubectl get serviceaccount -n kube-system tiller
  ```
  {: codeblock}

3. Initialize the Helm CLI and install Tiller in your cluster with the service account that you created.

  ```
  helm init --service-account tiller
  ```
  {: codeblock}

4. {{site.data.keyword.datashield_short}} uses [`cert-manager`](https://cert-manager.readthedocs.io/en/latest/){: external} to set up TLS certificates for internal communication between {{site.data.keyword.datashield_short}} services. To work with the service, install an instance of `cert-manager` by using Helm.

  ```
  helm repo update && helm install --version 0.5.0 stable/cert-manager
  ```
  {: codeblock}


## Installing the Helm chart
{: #install-chart}

Now that you've installed the prerequisites and created and configured your secrets, you're ready to install the service. You can use the provided Helm chart to install {{site.data.keyword.datashield_short}} on your SGX-enabled bare metal cluster.

The Helm chart installs the following components:

*	The supporting software for SGX.
*	The {{site.data.keyword.datashield_short}} Enclave Manager, which manages SGX enclaves in the {{site.data.keyword.datashield_short}} environment.
*	The container conversion service, which allows containerized applications to run in the {{site.data.keyword.datashield_short}} environment.


1. Get the information that you need to set up [backup and restore](/docs/data-shield?topic=data-shield-backup-restore) capabilities.

2. Install the chart.

  ```
  helm install iks-charts/ibmcloud-data-shield --set enclaveos-chart.Manager.AdminEmail=<admin email> --set enclaveos-chart.Manager.AdminName=<admin name> --set enclaveos-chart.Manager.AdminIBMAccountId=<hex account ID> --set global.IngressDomain=<your cluster's ingress domain>
  ```
  {: codeblock}

3. Enable High Availability (HA) for {{site.data.keyword.datashield_short}} services.
if you are working with multi node kubernetes cluster, then you can choose to have HA enabled for {{site.data.keyword.datashield_short}} services. This can be done using the <code>--set global.ServiceReplicas=<replica-count></code> command mentioned in the table below y specifying the replica count.

  <table>
    <caption>Table 1. Installation options</caption>
    <tr>
      <th>Command</th>
      <th>Description</th>
    </tr>
    <tr>
      <td><code>--set converter-chart.Converter.DockerConfigSecret=converter-docker-config</code></td>
      <td>Optional: If you [configured an {{site.data.keyword.cloud_notm}} Container Registry](/docs/data-shield?topic=data-shield-convert) you must append the Docker configuration to the installation command.</td>
    </tr>
    <tr>
      <td><code>--set global.OpenShiftEnabled=true</code></td>
      <td>Optional: If you are working with an {{site.data.keyword.openshiftshort}} cluster, be sure to append the {{site.data.keyword.openshiftshort}} tag to your installation command.</td>
    </tr>
    <tr>
      <td><code>--set Manager.FailOnGroupOutOfDate=true</code></td>
      <td>Optional: By default, node enrollment and the issueing of application certificates succeed. If you want the operations to fail if your platform microcode is out of date, append the flag to your install command. You are alerted in your dashboard when your service code is out of date. Note: It is not possible to change this option on existing clusters.</td>
    </tr>
    <tr>
      <td><code>--set enclaveos-chart.Ias.Mode=IAS_API_KEY</code></td>
      <td>Optional: You can use your own IAS API key. To do so, you must first obtain a linkable subscription for the Intel SGX Attestation Service. Then, generate a secret in your cluster by running the following command: <code>kubectl create secret generic ias-api-key --from-literal=env=<TEST/PROD> --from-literal=spid=<spid> --from-literal=api-key=<apikey></code>. Note: By default, IAS requests are made through a proxy service.</td>
    </tr>
    <tr>
      <td><code>--set global.ServiceReplicas=<replica-count></code></td>
      <td>Optional: Enable HA by specifying the replica count. This will deploy the Datashield DB and Backend DataShield Manager with HA capabilities. Note: The maximum replica count should be less than or equal to the number of nodes.</td>
    </tr>
  </table>

8. To monitor the startup of your components, you can run the following command.

  ```
  kubectl get pods
  ```
  {: codeblock}
