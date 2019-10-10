---

copyright:
  years: 2018, 2019
lastupdated: "2019-08-29"

keywords: Data protection, data in use, runtime encryption, runtime memory encryption, encrypted memory, Intel SGX, software guard extensions, Fortanix runtime encryption

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

# Installing
{: #install}

You can install {{site.data.keyword.datashield_full}} by using either the provided Helm chart or by using the provided installer. You can work with the installation commands that you feel most comfortable with.
{: shortdesc}

## Before you begin
{: #begin}

Before you can begin working with {{site.data.keyword.datashield_short}}, you must have the following prerequisites. For help with downloading the CLIs and plug-ins or configuring your Kubernetes Service environment, check out the tutorial, [creating Kubernetes clusters](/docs/containers?topic=containers-cs_cluster_tutorial#cs_cluster_tutorial_lesson1).

* The following CLIs:

  * [{{site.data.keyword.cloud_notm}}](/docs/cli/reference/ibmcloud?topic=cloud-cli-install-ibmcloud-cli)
  * [Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl/){: external}
  * [Docker](https://docs.docker.com/install/){: external}
  * [Helm](/docs/containers?topic=containers-helm)

* The following [{{site.data.keyword.cloud_notm}} CLI plug-ins](/docs/cli/reference/ibmcloud?topic=cloud-cli-plug-ins#plug-ins):

  * {{site.data.keyword.containershort_notm}}
  * {{site.data.keyword.registryshort_notm}}

* An SGX-enabled Kubernetes cluster. Currently, SGX can be enabled on a bare metal cluster with node type: `mb2c.4x32` or `ms2c.4x32.1.9tb.ssd`. If you don't have one, you can use the following steps to help ensure that you create the cluster that you need.

  To see the `mb2c.4x32` option, you must check the **Ubuntu 16** operating system.
  {: note}

  1. Prepare to [create your cluster](/docs/containers?topic=containers-clusters#cluster_prepare).

  2. Ensure that you have the [required permissions](/docs/containers?topic=containers-users) to create a cluster.

  3. Create the [cluster](/docs/containers?topic=containers-clusters).

* An instance of the [cert-manager](https://cert-manager.readthedocs.io/en/latest/){: external} service version 0.5.0 or newer. To install the instance by using Helm, you can run the following command.

  ```
  helm repo update && helm install --version 0.5.0 stable/cert-manager
  ```
  {: codeblock}

Want to see logging information for Data Shield? Set up an {{site.data.keyword.la_full_notm}} instance for your cluster.
{: tip}


## Installing with Helm
{: #install-chart}

You can use the provided Helm chart to install {{site.data.keyword.datashield_short}} on your SGX-enabled bare metal cluster.
{: shortdesc}

The Helm chart installs the following components:

*	The supporting software for SGX, which is installed on the bare metal hosts by a privileged container.
*	The {{site.data.keyword.datashield_short}} Enclave Manager, which manages SGX enclaves in the {{site.data.keyword.datashield_short}} environment.
*	The EnclaveOS® container conversion service, which allows containerized applications to run in the {{site.data.keyword.datashield_short}} environment.

If you have a previous version of {{site.data.keyword.datashield_short}} installed on your cluster, you must [uninstall](/docs/services/data-shield?topic=data-shield-uninstall) that version before you can install this release. Upgrading your version does not install this release.
{: note}

To install {{site.data.keyword.datashield_short}} onto your cluster:

1. Log in to the {{site.data.keyword.cloud_notm}} CLI. Follow the prompts in the CLI to complete logging in. If you have a federated ID, append the `--sso` option to the end of the command.

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

  2. Copy the output beginning with `export` and paste it into your terminal to set the `KUBECONFIG` environment variable.

3. If you haven't already, add the `iks-charts` repository.

  ```
  helm repo add iks-charts https://icr.io/helm/iks-charts
  ```
  {: codeblock}

4. Optional: If you don't know the email that is associated with the administrator or the admin account ID, run the following command.

  ```
  ibmcloud account show
  ```
  {: codeblock}

5. Get the Ingress subdomain for your cluster.

  ```
  ibmcloud ks cluster-get <cluster_name>
  ```
  {: codeblock}

6. Get the information that you need to set up [backup and restore](/docs/services/data-shield?topic=data-shield-backup-restore) capabilities.

7. Initialize Helm by creating a role binding policy for Tiller.

  1. Create a service account for Tiller.

    ```
    kubectl --namespace kube-system create serviceaccount tiller
    ```
    {: codeblock}

  2. Create the role binding to assign Tiller admin access in the cluster.

    ```
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    ```
    {: codeblock}

  3. Initialize Helm.

    ```
    helm init --service-account tiller --upgrade
    ```
    {: codeblock}

  You might want to configure Helm to use `--tls` mode. For help with enabling TLS check out the [Helm repository](https://github.com/helm/helm/blob/master/docs/tiller_ssl.md){: external}. If you enable TLS, be sure to append `--tls` to every Helm command that you run. For more information about using Helm with IBM Cloud Kubernetes Service, see [Adding services by using Helm Charts](/docs/containers?topic=containers-helm#public_helm_install).
  {: tip}

8. Install the chart.

  ```
  helm install iks-charts/ibmcloud-data-shield --set enclaveos-chart.Manager.AdminEmail=<admin email> --set enclaveos-chart.Manager.AdminName=<admin name> --set enclaveos-chart.Manager.AdminIBMAccountId=<hex account ID> --set global.IngressDomain=<your cluster's ingress domain>
  ```
  To deploy {{site.data.keyword.datashield_full}} on an OpenShift cluster, specify ```--set global.OpenShiftEnabled=true``` when installing the helm chart.
  {: note}

  {: codeblock}

  <table>
    <caption>Table 1. Installation options</caption>
    <tr>
      <th>Command</th>
      <th>Description</th>
    </tr>
    <tr>
      <td><code>--set converter-chart.Converter.DockerConfigSecret=converter-docker-config</code></td>
      <td>Optional: If you [configured an {{site.data.keyword.cloud_notm}} Container Registry](/docs/services/data-shield?topic=data-shield-convert) you must append the Docker configuration to the installation command.</td>
    </tr>
    <!-- <tr>
      <td><code>--set global.ServiceReplicas=<Number of Service Replicas></code></td>
      <td>Optional: Used to enable high availability by allow multiple instances of IBM Cloud Data Shield components to run. The number of service replicas must be less than or equal to the number of available nodes in your Kubernetes cluster. To ensure high availability, we recommend having a minimum of three replicas.</td>
    </tr>
    <tr>
      <td><code>--set enclaveos-chart.Ias.Mode=IAS_CREDENTIALS</code></td>
      <td>Optional: You can use your own IAS credentials. To do so, you must first generate a secret in your cluster by running the following command: <code>kubectl create secret generic ias-credentials --from-file=ias-credentials.crt --from-file=ias-credentials.key --from-literal=env=<TEST/PROD> --from-literal=spid=<spid></code></td>
    </tr>
    <tr>
      <td><code>--set enclaveos-chart.Ias.Mode=IAS_API_KEY</code></td>
      <td>Optional: You can use your own IAS API key. To do so, you must first generate a secret in your cluster by running the following command: <code>kubectl create secret generic ias-api-key --from-literal=env=<TEST/PROD> --from-literal=spid=<spid> --from-literal=api-key=<apikey>. Note: By default, IAS requests are made through a proxy service.</code></td>
    </tr> -->
  </table>

9. To monitor the startup of your components, you can run the following command.

  ```
  kubectl get pods
  ```
  {: codeblock}
