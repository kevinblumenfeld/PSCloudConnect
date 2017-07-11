---
external help file: PSCloudConnect-help.xml
online version: 
schema: 2.0.0
---

# Get-LAConnected

## SYNOPSIS
Connects to Office 365 services and/or Azure

To install:
Install-Module PSCloudConnect -Scope CurrentUser

To update to the latest version:
Update-Module PSCloudConnect

## SYNTAX

```
Get-LAConnected [-Tenant] <String> [-ExchangeAndMSOL] [-All365] [-Azure] [-Skype] [-SharePoint] [-Compliance]
 [-AzureADver2] [-DeleteInvalid365Creds] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Connects to Office 365 services and/or Azure.

Connects to some or all of the Office 365/Azure services based on switches provided at runtime.

Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter
When connecting to just Azure, it is still required to provide a unique name for the -Tenant parameter.

Locally saves and encrypts to a file the username and password.
The encrypted file...
   
1.  can only be used on the computer and within the user's profile from which it was created.
2.  is the same .txt file for all the Office 365 Services.
3.  for Azure is a separate .json file.

If Azure or AzureOnly switch is used **for first time**:

1.  User will login as normal when prompted by Azure
2.  User will be prompted to select which Azure Subscription
3.  Select the subscription and click "OK"

If Azure or AzureOnly switch is used:

1.  User will be prompted to pick username used previously
2.  If a new username is to be used (e.g. username not found when prompted), click Cancel to be prompted to login.
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
Get-LAConnected -Tenant Contoso -ExchangeAndMSOL
```

Connects to MS Online Service (MSOL) and Exchange Online

The tenant must be specified, for example either contoso or contoso.onmicrosoft.com

### -------------------------- EXAMPLE 2 --------------------------
```
Get-LAConnected -Tenant Contoso -Skype -Azure -ExchangeAndMSOL
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

There is a switch, DeleteInvalid365Creds which can be used if invalid credentials were inadvertently entered.
Typically a user can still login but they are prompted each time instead of using a saved credential.
Use this switch with the Tenant parameter to delete the appropriate credentials.
This will allow the user to enter credentials, at which point they will be properly saved for future use.

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
Get-LAConnected -Tenant Contoso -Skype -ExchangeAndMSOL
```

Connects to MS Online Service (MSOL) and Exchange Online and Skype Online

## PARAMETERS

### -Tenant
{{The Tenant Name}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExchangeAndMSOL
{{Exchange and MSOnline}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -All365
{{All Office 365 Services}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Azure
{{Microsoft Azure}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skype
{{Microsoft Skype}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SharePoint
{{Microsoft SharePoint}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Compliance
{{Office 365 Security and Compliance Center}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AzureADver2
{{Azure Active Directory Version 2}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeleteInvalid365Creds
{{Deletes credentials associated with tenant}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

