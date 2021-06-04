---

copyright:
  years: 2018, 2021
lastupdated: "2021-06-04"

keywords: assigning access, enclave manager, access control, managing users, cluster roles, cluster permissions, kube security, data protection, encryption, 

subcollection: data-shield
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


# Assigning access
{: #access}

You can give access to the Enclave Manager to users that might need to deploy, convert, or delete applications from the {{site.data.keyword.datashield_full}} environment.
{: shortdesc}

This type of access control is separate from the typical Identity and Access Management (IAM) roles that you use when you are working with {{site.data.keyword.cloud_notm}}.
{: tip}

## Assigning account access
{: #access-account}

Before you can invite other users to use your account, you must be an account owner or admin.
{: shortdesc}

1. Sign in to your account.

2. Go to **Manage > Access (IAM) > Users**.

3. Click **Invite users**.

4. Enter the email addresses for the users that you want to add. You can enter up to 100 at a time separated by commas, spaces, or line breaks.

5. Click **Invite**. 

There is no need to assign additional access to specific resources.
{: tip}



## Setting roles for Enclave Manager users
{: #enclave-roles}
{: support}

Data Shield administration takes place in the Enclave Manager. As an administrator, you are automatically assigned the *manager* role, but you can also assign roles to other users.
{: shortdesc}

Check out the following table to see which roles are supported and some example actions that can be taken by each user:

| Role | Actions | Example |
|-----|----| ------ |
| Viewer | Can perform read-only actions such as viewing nodes, builds, user information, apps, tasks, and audit logs. | Downloading a node attestation certificate. |
| Editor | Can perform the actions that a Viewer can perform and more; including deactivating and renewing node attestation, adding a build, and approving or denying any action or tasks. | Certifying an application. |
| Administrator | Can perform the actions that an Editor can perform and more; including updating usernames and roles, adding users to the cluster, updating cluster settings, and any other privileged actions. | Updating a user role. |
{: caption="Table 1. Example actions" caption-side="top"}


### Adding a user
{: #set-roles}

By using the Enclave Manager GUI, you can give new user's access to the information.
{: shortdesc}

1. Sign in to the Enclave Manager.

2. Click **Your name > Settings**.

3. Click **Add user**.

4. Enter an email and a name for the user. Select a role from the **Role** drop down.

5. Click **Save**.



### Updating a user
{: #update-roles}

You can update the roles that are assigned to your users and their name.
{: shortdesc}

1. Sign in to the [Enclave Manager UI](/docs/data-shield?topic=data-shield-enclave-manager#em-signin).

2. Click **Your name > Settings**.

3. Hover over the user whose permissions you want to edit. A pencil icon shows.

4. Click the pencil icon. The edit user screen opens.

5. From the **Role** drop down, select the roles that you want to assign.

6. Update the user's name.

7. Click **Save**. Any changes to a user's permissions take immediate effect.


