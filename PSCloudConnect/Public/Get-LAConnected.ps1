<#
.EXTERNALHELP PSCloudConnect-help.xml
#>
function Get-LAConnected {
 
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (

        [parameter(Position = 0, Mandatory = $true)]
        [string] $Tenant,

        [parameter(Position = 1, Mandatory = $false)]
        [string] $User,
                           
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
        if (! $User) {
            $User = "Default"
        }
    }
    Process {

        $RootPath = $env:USERPROFILE + "\ps\"
        $KeyPath = $Rootpath + "creds\"

        # Delete invalid or unwanted credentials
        if ($Delete365Creds) {
            Remove-Item ($KeyPath + "$($Tenant).$($user).cred") 
            Remove-Item ($KeyPath + "$($Tenant).$($user).ucred")
        }
        # Create Directory for Transact Logs
        if (!(Test-Path ($RootPath + $Tenant + "\logs\"))) {
            New-Item -ItemType Directory -Force -Path ($RootPath + $Tenant + "\logs\")
        }
        Try {
            Start-Transcript -ErrorAction Stop -path ($RootPath + $Tenant + "\logs\" + "transcript-" + ($(get-date -Format _yyyy-MM-dd_HH-mm-ss)) + ".txt") 
        }
        Catch {
            Stop-Transcript 
            Start-Transcript -path ($RootPath + $Tenant + "\logs\" + "transcript-" + ($(get-date -Format _yyyy-MM-dd_HH-mm-ss)) + ".txt")
        }
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
            if (Test-Path ($KeyPath + "$($Tenant).$($user).cred")) {
                $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).$($user).cred") | ConvertTo-SecureString
                $UsernameString = Get-Content ($KeyPath + "$($Tenant).$($user).ucred")
                $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $UsernameString, $PwdSecureString 
            }
            else {
                $Credential = Get-Credential -Message "Enter a username and password"
                $Credential.Password | ConvertFrom-SecureString | Out-File ($KeyPath + "$($Tenant).$($user).cred") -Force
                $Credential.UserName | Out-File ($KeyPath + "$($Tenant).$($user).ucred")
            }
        }
        if ($MSOnline -or $All365) {
            # Office 365 Tenant
            Try {
                Import-Module MsOnline -ErrorAction Stop
            }
            Catch {
                Write-Output "MSOnline module is required"
                Write-Output "To download the prerequisite and MSOnline module:"
                Write-Output "https://technet.microsoft.com/en-us/library/dn975125.aspx"
            }
            Connect-MsolService -Credential $Credential
        }
        if ($Exchange -or $All365) {
            if (! $MFA) {
                # Exchange Online
                $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection 
                Import-Module (Import-PSSession $exchangeSession -AllowClobber) -Global | Out-Null
            }
            else {
                Try {
                    Connect-EXOPSSession -UserPrincipalName $Credential.UserName -erroraction Stop
                } 
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Output "Exchange Online MFA module is required"
                    Write-Output "To download the Exchange Online Remote PowerShell Module for multi-factor authentication,"
                    Write-Output "in the EAC (https://outlook.office365.com/ecp/), go to Hybrid > Setup and click the appropriate Configure button."
                }
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
                Try {
                    $sfboSession = New-CsOnlineSession -ErrorAction Stop -Credential $Credential
                }
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Output "Skype for Business Online Module not found.  Please download and install it from here:"
                    Write-Output "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
                }
                Catch {
                    $_
                }
                Import-Module (Import-PSSession $sfboSession -AllowClobber) -Global | Out-Null
            }
            else {
                Try {
                    $sfboSession = New-CsOnlineSession -UserName $Credential.UserName -ErrorAction Stop
                }
                Catch [System.Management.Automation.CommandNotFoundException] {
                    Write-Output "Skype for Business Online Module not found.  Please download and install it from here:"
                    Write-Output "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
                }
                Catch {
                    $_
                }
            }
        }
        # SharePoint Online
        if ($SharePoint -or $All365) {
            Try {
                Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction Stop
            }
            Catch {
                Write-Output "Unable to import SharePoint Module"
                Write-Output "Ensure it is installed, Download it from here: https://www.microsoft.com/en-us/download/details.aspx?id=35588"
            }
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
            if (! $MFA) {
                Try {
                    install-module azuread -AllowClobber -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                    import-module azuread -Force -ErrorAction Stop
                    Connect-AzureAD -Credential $Credential -ErrorAction Stop
                }
                Catch {
                    Write-Output "There was an error Connecting to Azure Ad - Ensure the module is installed"
                    Write-Output "Download PowerShell 5 or PowerShellGet"
                    Write-Output "https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure"
                }
            }
            else {
                Try {
                    install-module azuread -AllowClobber -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                    import-module azuread -Force -ErrorAction Stop
                    Connect-AzureAD -ErrorAction Stop
                }
                Catch {
                    Write-Output "There was an error Connecting to Azure Ad - Ensure the module is installed"
                    Write-Output "Download PowerShell 5 or PowerShellGet"
                    Write-Output "https://msdn.microsoft.com/en-us/powershell/wmf/5.1/install-configure"
                }
            }
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
            Try {
                install-module AzureRM -Force -erroraction continue
                $azlogin = Login-AzureRmAccount -erroraction continue
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Output "Download and install PowerShell 5.1 or PowerShellGet so the AzureRM module can be automatically installed"
                Write-Output "https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0#how-to-get-powershellget"
                Write-Output "or download the MSI installer and install from here: https://github.com/Azure/azure-powershell/releases"
                Break
            }
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
        Try {
            Login-AzureRmAccount -ErrorAction Stop
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            Write-Output "Download and install PowerShell 5.1 or PowerShellGet so the AzureRM module can be automatically installed"
            Write-Output "https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.2.0#how-to-get-powershellget"
            Write-Output "or download the MSI installer and install from here: https://github.com/Azure/azure-powershell/releases"
            Break
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
            Write-Output "There was an error selecting your subscription ID"
        }

    }

}
