#define MyAppName "Manshoor Inventory"
#define MyAppVersion "1.0.5"
#define MyAppPublisher "Manshoor Communications"

[Setup]
AppId={{A7F2E5C1-4B8D-4D52-9C41-MANSHOORINV001}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName=C:\ManshoorInventory
DefaultGroupName={#MyAppName}

OutputDir=output
OutputBaseFilename=ManshoorInventory-V1.0.5-Setup

Compression=lzma
SolidCompression=yes

PrivilegesRequired=admin
DisableProgramGroupPage=yes

[Files]
Source: "stage\app.py"; DestDir: "{app}"
Source: "stage\requirements.txt"; DestDir: "{app}"
Source: "stage\Dockerfile"; DestDir: "{app}"
Source: "stage\docker-compose.yml"; DestDir: "{app}"

Source: "stage\app\*"; DestDir: "{app}\app"; Flags: recursesubdirs createallsubdirs

Source: "stage\backup_inventory.sh"; DestDir: "{app}"
Source: "stage\Start-ManshoorInventory.bat"; DestDir: "{app}"
Source: "stage\Restore-ManshoorInventory.bat"; DestDir: "{app}"
Source: "stage\Select-BackupPath.ps1"; DestDir: "{app}"
Source: "stage\ManshoorInventory-Protocol.ps1"; DestDir: "{app}"
Source: "config\backup-path.txt"; DestDir: "{app}\config"; Flags: onlyifdoesntexist
Source: "stage\manshoor-inventory-v1.0.5.tar"; DestDir: "{app}"
[Registry]
Root: HKCR; Subkey: "manshoor-inventory"; ValueType: string; ValueName: ""; ValueData: "URL:Manshoor Inventory Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "manshoor-inventory"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletevalue
Root: HKCR; Subkey: "manshoor-inventory\shell\open\command"; ValueType: string; ValueName: ""; ValueData: "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""{app}\ManshoorInventory-Protocol.ps1"" ""%1"""; Flags: uninsdeletekey

[Dirs]
Name: "{app}\instance"
Name: "{app}\backups"
Name: "{app}\config"

[Icons]
Name: "{group}\Manshoor Inventory"; Filename: "{app}\Start-ManshoorInventory.bat"
Name: "{commondesktop}\Manshoor Inventory"; Filename: "{app}\Start-ManshoorInventory.bat"

