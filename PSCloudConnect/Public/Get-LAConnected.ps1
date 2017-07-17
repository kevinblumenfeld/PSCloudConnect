<#
.EXTERNALHELP PSCloudConnect-help.xml
#>
function Get-LAConnected {
 
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (

        [parameter(Mandatory = $true)]
        [string] $Tenant,
                           
        [Parameter(Mandatory = $false)]
        [switch] $Exchange,
                              
        [Parameter(Mandatory = $false)]
        [switch] $MSOnline,
                       
        [Parameter(Mandatory = $false)]
        [switch] $All365,
                
        [Parameter(Mandatory = $false)]
        [switch] $Azure,    

        [parameter(Mandatory = $false)]
        [switch] $Skype,
          
        [parameter(Mandatory = $false)]
        [switch] $SharePoint,
         
        [parameter(Mandatory = $false)]
        [switch] $Compliance,

        [parameter(Mandatory = $false)]
        [switch] $AzureADver2,
               
        [Parameter(Mandatory = $false)]
        [switch] $MFA,

        [parameter(Mandatory = $false)]
        [switch] $Delete365Creds
        
    )

    Begin {
        if ($Tenant -match 'onmicrosoft') {
            $Tenant = $Tenant.Split(".")[0]
        }
    }
    Process {

        $RootPath = $env:USERPROFILE + "\ps\"
        $KeyPath = $Rootpath + "creds\"

        # Delete invalid or unwanted credentials
        if ($Delete365Creds) {
            Remove-Item ($KeyPath + "$($Tenant).cred") 
            Remove-Item ($KeyPath + "$($Tenant).ucred")
        }
        # Create Directory for Transact Logs
        if (!(Test-Path ($RootPath + $Tenant + "\logs\"))) {
            New-Item -ItemType Directory -Force -Path ($RootPath + $Tenant + "\logs\")
        }

        Start-Transcript -path ($RootPath + $Tenant + "\logs\" + "transcript-" + ($(get-date -Format _yyyy-MM-dd_HH-mm-ss)) + ".txt")

        # Create KeyPath Directory
        if (!(Test-Path $KeyPath)) {
            try {
                New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP | Out-Null
            }
            catch {
                throw $_.Exception.Message
            }           
        }
        if ($Exchange -or $MSOnline -or $All365 -or $Skype -or $SharePoint -or $Compliance -or $AzureADver2) {
            if (Test-Path ($KeyPath + "$($Tenant).cred")) {
                $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
                $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred") 
                $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $UsernameString, $PwdSecureString 
            }
            else {
                $Credential = Get-Credential -Message "Enter a username and password"
                $Credential.Password | ConvertFrom-SecureString | Out-File "$($KeyPath)\$Tenant.cred" -Force
                $Credential.UserName | Out-File "$($KeyPath)\$Tenant.ucred"
            }
        }
        if ($MSOnline -or $All365) {
            # Office 365 Tenant
            Import-Module MsOnline
            Connect-MsolService -Credential $Credential
        }
        if ($Exchange -or $All365) {
            if (! $MFA) {
                # Exchange Online
                $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection 
                Import-Module (Import-PSSession $exchangeSession -AllowClobber) -Global | Out-Null
            }
            else {
                Connect-EXOPSSession -UserPrincipalName $Credential.UserName
            }
        }
        # Security and Compliance Center
        if ($Compliance -or $All365 -and (! $MFA)) {
            $ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
            Import-Module (Import-PSSession $ccSession -AllowClobber) -Global | Out-Null
        }
        # Skype Online
        if ($Skype -or $All365) {
            if (! $MFA) {
                $sfboSession = New-CsOnlineSession -Credential $Credential
                Import-Module (Import-PSSession $sfboSession -AllowClobber) -Global | Out-Null
            }
            else {
                $sfboSession = New-CsOnlineSession -UserName $Credential.UserName
            }
        }
        # SharePoint Online
        if ($SharePoint -or $All365) {
            Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking 
            if (! $MFA) {
                Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com") -credential $Credential
            }
            else {
                Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com")
            }
        }
        # Azure
        if ($Azure) {
            Get-LAAzureConnected
        }
        # Azure AD
        If ($AzureADver2) {
            install-module azuread -AllowClobber -Force
            import-module azuread -Force
            Connect-AzureAD -Credential $Credential
        }
    }
    End {
    } 
}

function Get-LAAzureConnected {
    if (! $MFA) {
        $json = Get-ChildItem -Recurse -Include '*@*.json' -Path $KeyPath
        if ($json) {
            Write-Host   "************************************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Host   "************************************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Output "   Select the Azure username and Click `"OK`" in lower right-hand corner"
            Write-Output "   Otherwise, if this is the first time using this Azure username click `"Cancel`""
            Write-Host   "************************************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Host   "************************************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            $json = $json | select name | Out-GridView -PassThru -Title "Select Azure username or click Cancel to use another"
        }
        if (!($json)) {
            $azlogin = Login-AzureRmAccount
            Save-AzureRmContext -Path ($KeyPath + ($azlogin.Context.Account.Id) + ".json")
            Import-AzureRmContext -Path ($KeyPath + ($azlogin.Context.Account.Id) + ".json")
        }
        else {
            Import-AzureRmContext -Path ($KeyPath + $json.name)
        }
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        Write-Output "   Select Subscription and Click `"OK`" in lower right-hand corner"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        $subscription = Get-AzureRmSubscription | Out-GridView -PassThru -Title "Choose Azure Subscription"| Select id
        Try {
            Select-AzureRmSubscription -SubscriptionId $subscription.id -ErrorAction Stop
        }
        Catch {
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Output "   Azure credentials have expired. Authenticate again please."
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        
            Remove-Item ($KeyPath + $json.name)
            Get-LAAzureConnected
        }
    }
    else {
        Login-AzureRmAccount
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        Write-Output "   Select Subscription and Click `"OK`" in lower right-hand corner"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        Write-Host   "*********************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
        $subscription = Get-AzureRmSubscription | Out-GridView -PassThru -Title "Choose Azure Subscription"| Select id
        Try {
            Select-AzureRmSubscription -SubscriptionId $subscription.id -ErrorAction Stop
        }
        Catch {
            Write-Output "There was an error selecting your subscription ID"
        }

    }

}
