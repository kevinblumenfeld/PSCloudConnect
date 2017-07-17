# Get-LAConnected

## SYNOPSIS
Connects to Office 365 services and/or Azure

**To install:**
Install-Module PSCloudConnect -Scope CurrentUser

**To update to the latest version:**
Update-Module PSCloudConnect

## SYNTAX

```
Get-LAConnected [-Tenant] <String> [-Exchange] [-MSOnline] [-All365] [-Azure] [-Skype] [-SharePoint]
 [-Compliance] [-AzureADver2] [-MFA] [-Delete365Creds] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Connects to Office 365 services and/or Azure.

Connects to some or all of the Office 365/Azure services based on switches provided at runtime.

Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter
When connecting to just Azure, it is still required to provide a unique name for the -Tenant parameter.

There is a switch to use Multi-Factor Authentication.  For Exchange Online MFA, you are required to download and use the Exchange Online Remote PowerShell Module.
To download the Exchange Online Remote PowerShell Module for multi-factor authentication, in the EAC (https://outlook.office365.com/ecp/), go to Hybrid > Setup and click the appropriate Configure button.  When using Multi-Factor Authentication the saving of credentials is not available currently - thus each service will prompt independently for credentials.  Also the Security and Compliance Center does not currently support multi-factor authentication.

Locally saves and encrypts to a file the username and password.
The encrypted file...can only be used on the computer and within the user's profile from which it was created, is the same .txt file for all the Office 365 services and is a separate .json file for Azure.

If Azure or AzureOnly switch is used **for first time**:

1.  User will login as normal when prompted by Azure
2.  User will be prompted to select which Azure Subscription
3.  Select the subscription and click "OK"

If Azure or AzureOnly switch is used:

1.  User will be prompted to pick username used previously
2.  If a new username is to be used (e.g. username not found when prompted), click **Cancel** to be prompted to login.
3.  User will be prompted to select which Azure Subscription
4.  Select the subscription and click "OK"

Directories used/created during the execution of this script 

1.  $env:USERPROFILE\ps\
2.  $env:USERPROFILE\ps\creds\

All saved credentials are saved in $env:USERPROFILE\ps\creds\
Transcript is started and kept in $env:USERPROFILE\ps\<tenantspecified\>

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-LAConnected -Tenant Contoso -Exchange -MSOnline
```

Connects to MS Online Service (MSOL) and Exchange Online

The tenant must be specified, for example either contoso or contoso.onmicrosoft.com

### -------------------------- EXAMPLE 2 --------------------------
```
Get-LAConnected -Tenant Contoso -Skype -Azure -Exchange -MSOnline
```

Connects to Azure, MS Online Service (MSOL), Exchange Online & Skype

This is to illustrate that any number of individual services can be used to connect.

### -------------------------- EXAMPLE 3 --------------------------
```
Get-LAConnected -Tenant Contoso -SharePoint
```

Connects to SharePoint Online

### -------------------------- EXAMPLE 4 --------------------------
```
Get-LAConnected -Tenant Contoso -DeleteInvalid365Creds
```

The switch, DeleteInvalid365Creds can be used if invalid credentials were inadvertently entered.
Typically, the symptom would be a user would be prompted each time for credentials, as the saved credential is invalid.
Use this switch with the mandatory Tenant parameter to delete the appropriate credentials.
Credentials will then be saved on the following login.

### -------------------------- EXAMPLE 5 --------------------------
```
Get-LAConnected -Tenant Contoso -Compliance
```

Connects to Compliance & Security Center

### -------------------------- EXAMPLE 6 --------------------------
```
Get-LAConnected -Tenant Contoso -All365
```

Connects to MS Online Service (MSOL), Exchange Online, Skype, SharePoint & Compliance

### -------------------------- EXAMPLE 7 --------------------------
```
Get-LAConnected -Tenant Contoso -All365 -Azure
```

Connects to Azure, MS Online Service (MSOL), Exchange Online, Skype, SharePoint & Compliance

### -------------------------- EXAMPLE 8 --------------------------
```
Get-LAConnected -Tenant Contoso -Skype -Exchange -MSOnline
```

Connects to MS Online Service (MSOL) and Exchange Online and Skype Online
