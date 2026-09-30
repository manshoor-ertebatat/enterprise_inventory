param(
    [string]$Url
)

if ([string]::IsNullOrWhiteSpace($Url)) {
    exit 1
}

try {
    $uri = [System.Uri]$Url

    if ($uri.Scheme -ne "manshoor-inventory") {
        exit 1
    }

    if ($uri.Host -ne "select-backup") {
        exit 1
    }

    # Extract token from query string without System.Web dependency
    $token = $null

    if (-not [string]::IsNullOrWhiteSpace($uri.Query)) {
        $query = $uri.Query.TrimStart("?")

        foreach ($item in $query -split "&") {
            $parts = $item -split "=", 2

            if ($parts.Count -eq 2 -and $parts[0] -eq "token") {
                $token = [Uri]::UnescapeDataString($parts[1])
                break
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($token)) {
        exit 1
    }

    $scriptPath = "C:\ManshoorInventory\Select-BackupPath.ps1"

    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        exit 1
    }

    Start-Process powershell.exe -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$scriptPath`"",
        "`"$token`""
    )
}
catch {
    exit 1
}
