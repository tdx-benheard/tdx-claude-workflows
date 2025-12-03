# Authenticate and prewarm TeamDynamix applications
param(
    [string]$Project = "TDNext",  # TDNext, TDClient, TDAdmin, or TDWorkManagement
    [string]$SpecificPage = ""
)

# Auto-detect virtual directory from active web.config
$webConfigPath = "$PSScriptRoot/../$Project/web.config"
if (Test-Path $webConfigPath) {
    $webConfigContent = Get-Content $webConfigPath -Raw
    if ($webConfigContent -match 'BaseHttpPath.*?value="/(.*?)/' ) {
        $virtualDir = $Matches[1]
        Write-Host "Auto-detected virtual directory: $virtualDir (from web.config BaseHttpPath)" -ForegroundColor Cyan
    } else {
        $virtualDir = "TDDev"  # Default fallback
        Write-Host "Could not detect virtual directory, using default: $virtualDir" -ForegroundColor Yellow
    }
} else {
    $virtualDir = "TDDev"  # Default fallback
    Write-Host "No web.config found, using default virtual directory: $virtualDir" -ForegroundColor Yellow
}

$baseUrl = "http://localhost/$virtualDir/$Project"
$username = "bheard"
$password = "Password1!"

# Create a session to maintain cookies
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    # Get login page to extract ViewState
    $loginPage = Invoke-WebRequest -Uri "$baseUrl/Login.aspx" -SessionVariable session -UseBasicParsing

    # Extract form fields
    $viewState = ($loginPage.InputFields | Where-Object { $_.name -eq '__VIEWSTATE' }).value
    $viewStateGen = ($loginPage.InputFields | Where-Object { $_.name -eq '__VIEWSTATEGENERATOR' }).value
    $eventVal = ($loginPage.InputFields | Where-Object { $_.name -eq '__EVENTVALIDATION' }).value

    # Login
    $loginData = @{
        '__VIEWSTATE' = $viewState
        '__VIEWSTATEGENERATOR' = $viewStateGen
        '__EVENTVALIDATION' = $eventVal
        'txtUserName' = $username
        'txtPassword' = $password
        'btnSignIn' = 'Sign In'
    }

    $null = Invoke-WebRequest -Uri "$baseUrl/Login.aspx" -Method POST -Body $loginData -WebSession $session -UseBasicParsing -MaximumRedirection 10

    Write-Host "Authenticated successfully" -ForegroundColor Green

    # Prewarm main pages based on project
    Write-Host "Prewarming $Project..." -ForegroundColor Cyan
    $null = Invoke-WebRequest -Uri "$baseUrl/" -WebSession $session -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue

    # Different apps have different main endpoints
    switch ($Project) {
        "TDNext" {
            $null = Invoke-WebRequest -Uri "$baseUrl/Home/Desktop" -WebSession $session -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        }
        "TDClient" {
            $null = Invoke-WebRequest -Uri "$baseUrl/Home/Desktop" -WebSession $session -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        }
        "TDAdmin" {
            $null = Invoke-WebRequest -Uri "$baseUrl/Home" -WebSession $session -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        }
        "TDWorkManagement" {
            $null = Invoke-WebRequest -Uri "$baseUrl/Home/Index" -WebSession $session -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        }
    }

    # If TDNext, also prewarm TDWorkManagement (TDNext depends on it)
    if ($Project -eq "TDNext") {
        Write-Host "Also prewarming TDWorkManagement (TDNext dependency)..." -ForegroundColor Cyan
        $wmUrl = "http://localhost/$virtualDir/TDWorkManagement"
        $null = Invoke-WebRequest -Uri "$wmUrl/" -WebSession $session -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        $null = Invoke-WebRequest -Uri "$wmUrl/Home/Index" -WebSession $session -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
    }

    # Prewarm specific page if provided
    if ($SpecificPage) {
        Write-Host "Prewarming specific page: $SpecificPage" -ForegroundColor Cyan
        $null = Invoke-WebRequest -Uri $SpecificPage -WebSession $session -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
    }

    Write-Host "Prewarm complete!" -ForegroundColor Green
}
catch {
    Write-Host "Prewarm failed: $($_.Exception.Message)" -ForegroundColor Yellow
}
