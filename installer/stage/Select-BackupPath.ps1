Add-Type -AssemblyName System.Windows.Forms

function Show-Error($message) {
    [System.Windows.Forms.MessageBox]::Show(
        $message,
        "Manshoor Inventory - Error",
        "OK",
        "Error"
    )
}

$InstallDir = "C:\ManshoorInventory"
$ConfigDir = Join-Path $InstallDir "config"
$ConfigFile = Join-Path $ConfigDir "backup-path.txt"
$EnvFile = Join-Path $InstallDir ".env"
$ComposeFile = Join-Path $InstallDir "docker-compose.yml"
$LogFile = Join-Path $ConfigDir "backup-path-helper.log"

$Token = $null

if ($args.Count -gt 0) {
    $Token = $args[0]
}

if ([string]::IsNullOrWhiteSpace($Token)) {
    Show-Error "Authorization token was not provided."
    exit 1
}

# Check Administrator privileges
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Definition

    $argumentList = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$scriptPath`""
    )

    if (-not [string]::IsNullOrWhiteSpace($Token)) {
        $argumentList += $Token
    }

    Start-Process powershell.exe -Verb RunAs -ArgumentList $argumentList

    exit
}

# Validate authorization token with Manshoor Inventory
try {
    $authorizeUrl = "http://127.0.0.1:5003/backup/authorize-path?token=" + [Uri]::EscapeDataString($Token)

    $authorization = Invoke-RestMethod `
        -Uri $authorizeUrl `
        -Method Get `
        -TimeoutSec 5

    if (-not $authorization.authorized) {
        Show-Error "The authorization token is invalid or expired."
        exit 1
    }
}
catch {
    Show-Error "Could not validate the authorization token.`n`nPlease make sure Manshoor Inventory is running."
    exit 1
}

# Check Docker Compose file
if (-not (Test-Path -LiteralPath $ComposeFile -PathType Leaf)) {
    Show-Error "docker-compose.yml was not found.`n`n$ComposeFile"
    exit 1
}

# Select backup folder
$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = "Select Manshoor Inventory backup folder"
$dialog.ShowNewFolderButton = $true

$result = $dialog.ShowDialog()

if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
    exit
}

$selectedPath = $dialog.SelectedPath

if ([string]::IsNullOrWhiteSpace($selectedPath)) {
    Show-Error "No valid folder was selected."
    exit 1
}

# Save configuration
try {
    if (-not (Test-Path -LiteralPath $selectedPath -PathType Container)) {
        New-Item -ItemType Directory -Path $selectedPath -Force | Out-Null
    }

    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

    [System.IO.File]::WriteAllText(
        $ConfigFile,
        $selectedPath,
        $utf8NoBom
    )

    $dockerPath = $selectedPath -replace '\\', '/'

    [System.IO.File]::WriteAllText(
        $EnvFile,
        "MANSHOOR_BACKUP_PATH=`"$dockerPath`"",
        $utf8NoBom
    )
}
catch {
    Show-Error "Could not save the backup configuration.`n`n$($_.Exception.Message)"
    exit 1
}

# Apply Docker Compose configuration
try {
    Remove-Item -LiteralPath $LogFile -Force -ErrorAction SilentlyContinue

    Push-Location $InstallDir

    $composeCommand = 'docker compose up -d --force-recreate > "' + $LogFile + '" 2>&1'

    cmd.exe /c $composeCommand

    $exitCode = $LASTEXITCODE

    Pop-Location

    if ($exitCode -ne 0) {
        $log = Get-Content -LiteralPath $LogFile -Raw -ErrorAction SilentlyContinue

        Show-Error "Docker Compose failed.`n`n$log"
        exit 1
    }
}
catch {
    Pop-Location -ErrorAction SilentlyContinue

    Show-Error "Could not apply Docker Compose configuration.`n`n$($_.Exception.Message)"
    exit 1
}

# Wait for application
$ready = $false

for ($i = 0; $i -lt 30; $i++) {
    try {
        $response = Invoke-WebRequest `
            -UseBasicParsing `
            -Uri "http://127.0.0.1:5003" `
            -TimeoutSec 2

        if ($response.StatusCode -eq 200) {
            $ready = $true
            break
        }
    }
    catch {
    }

    Start-Sleep -Seconds 2
}

if (-not $ready) {
    Show-Error "The backup path was saved, but the application did not become ready.`n`nPlease check Docker Desktop.`n`nLog:`n$LogFile"
    exit 1
}

[System.Windows.Forms.MessageBox]::Show(
    "Backup path changed successfully:`n`n$selectedPath",
    "Manshoor Inventory",
    "OK",
    "Information"
)
