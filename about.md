---

copyright:
  years: 2018, 2019
lastupdated: "2019-01-08"

---

{:new_window: target="_blank"}
{:shortdesc: .shortdesc}
{:screen: .screen}
{:codeblock: .codeblock}
{:pre: .pre}
{:tip: .tip}
{:important: .important}
{:note: .note}

# About the service
{: #about}

With {{site.data.keyword.datashield_full}}, Fortanix®, and Intel® SGX you can protect the data in your container workloads that run on {{site.data.keyword.cloud_notm}} while your data is in use.
{: shortdesc}

When it comes to protecting your data, encryption is one of the most popular and effective controls. But the data must be encrypted at each step of its lifecycle. Data goes through three phases during its lifecycle: data-at-rest, data in motion, and data in use. Data at rest and in motion are commonly used to protect data when it is stored and when it is transported. Taking that protection one step further, you can now encrypt data in use. After the application starts to run, data in use by CPU and memory is vulnerable to a variety of attacks including malicious insiders, root users, credential compromise, OS zero-day, network intruders, and others.

{{site.data.keyword.datashield_short}} protects your {{site.data.keyword.Bluemix_notm}} container workload code and data are protected in use. The app code and data run in CPU-hardened enclaves, which are trusted areas of memory on the worker node that protect critical aspects of the app, which helps to keep the code and data confidential and unmodified. If you or your company require data sensitivity due to internal policies, government regulations, or industry compliance requirements, this solution might help you to move to the cloud. Example use cases include financial and healthcare institutions, or countries with government policies that require on-premises cloud solutions.

</br>

## Integrations
{: #integrations}

To provide the most seamless experience for you, {{site.data.keyword.datashield_short}} is integrated with other {{site.data.keyword.cloud_notm}} services, Fortanix® Runtime Encryption, and Intel SGX®.

<dl>
  <dt>Fortanix®</dt>
    <dd>With [Fortanix](http://fortanix.com/) you can keep your most valuable apps and data protected, even when the infrastructure is compromised. Built on Intel SGX, Fortanix provides a new category of data security called Runtime Encryption. Similar to the way encryption works for data at rest and data during motion, runtime encryption keeps keys, data, and applications completely protected from external and internal threats. The threats might include malicious insiders, cloud providers, OS-level hacks, or network intruders.</dd>
  <dt>Intel® SGX</dt>
    <dd>[Intel SGX](https://software.intel.com/en-us/sgx) is an extension to the x86 architecture that allows you to run applications in a completely isolated secure enclave. The application is not only isolated from other applications running on the same system, but also from the Operating System and possible Hypervisor. This prevents administrators from tampering with the application after it is started. The memory of secure enclaves is also encrypted to thwart physical attacks. The technology also supports storing persistent data securely such that it can only be read by the secure enclave.</dd>
  <dt>{{site.data.keyword.containerlong_notm}}</dt>
    <dd>[{{site.data.keyword.containerlong_notm}}](/docs/containers/index.html) delivers powerful tools by combining Docker containers, the Kubernetes technology, an intuitive user experience, and built-in security and isolation to automate the deployment, operation, scaling, and monitoring of containerized apps in a cluster of compute hosts.</dd>
  <dt>{{site.data.keyword.cloud_notm}} Identity and Access Management (IAM)</dt>
    <dd>[IAM](/docs/iam/quickstart.html) enables you to securely authenticate users for services and control access to resources consistently across {{site.data.keyword.cloud_notm}}. When a user tries to complete a specific action, the control system uses the attributes that are defined in the policy to determine whether the user has permission to perform that task. {{site.data.keyword.cloud_notm}} API keys are available through Cloud IAM for you to use to authenticate by using the CLI or as part of automation to log in as your user identity.</dd>
  <dt>{{site.data.keyword.loganalysislong}}</dt>
    <dd>You can create a [logging configuration](/docs/containers/cs_health.html#health) through the {{site.data.keyword.containerlong_notm}} that forwards your logs to [{{site.data.keyword.loganalysislong}}](/docs/services/CloudLogAnalysis/index.html). You can expand your log collection, log retention, and log search abilities in {{site.data.keyword.cloud_notm}}. Empower your DevOps team with features such as aggregation of application and environment logs for consolidated application or environment insights, encryption of logs, retention of log data for as long as it is needed, and quick detection and troubleshooting of issues.</dd>
</dl>

</br>
</br>