[CustomMessages]
AppExe=[[NAME]]

[Setup]
;SignTool=signtool ; Uncomment this line if you have configured a signtool in Inno Setup
AppName=[[NAME]]
AppVerName=[[NAME]] [[APP_VERSION]]
AppID=[[NAME]][[APP_VERSION]]
AllowNoIcons=No
AppPublisher=Bob Hall
AppPublisherURL=https://www.moduops.com
AppSupportURL=https://www.moduops.com
AppVersion=[[APP_VERSION]]
DefaultDirName={pf}\[[NAME]]
DefaultGroupName=[[NAME]]
UninstallDisplayIcon={app}\[[NAME]].exe
Compression=lzma
SolidCompression=yes
OutputDir=.\
OutputBaseFilename=ModuOps_Setup

UsePreviousTasks=Yes
VersionInfoCompany=Bob Hall
VersionInfoCopyright=Copyright (c) 2023 Robert D Hall
VersionInfoDescription=
VersionInfoProductVersion=
VersionInfoTextVersion=
VersionInfoVersion=[[VERSION]]
ShowLanguageDialog=no
ChangesAssociations=yes

[Languages]
; Uncomment this line if you have an end user license agreement
;Name: "english"; MessagesFile: "compiler:Default.isl"; LicenseFile: "..\..\..\build files\EULA.rtf"

[Files]
;; DLL used to check if the target program is running at install time
;Source: psvince.dll; flags: dontcopy
;; psvince is installed in {app} folder, so it will be loaded at
;; uninstall time to check if the target program is running
;Source: psvince.dll; DestDir: {app}

Source: ".\windows\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]

[UninstallDelete]
; Uncomment this example if your application stores information in the user data folder that should be removed.
;Type: filesandordirs; Name: "{userappdata}\[[NAME]]\[[APP_VERSION]]"

[Dirs]

[[DirectoriesToCreate]]

; Uncomment this example if your application stores information in the user data folder and a folder should be created.
;Name: "{userappdata}\[[NAME]]";

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags:

[Icons]
Name: "{group}\{cm:AppExe}"; Filename: "{app}\{cm:AppExe}.exe"
Name: "{group}\Uninstall {cm:AppExe}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\{cm:AppExe}"; Filename: "{app}\{cm:AppExe}.exe"; IconIndex: 0; Tasks: desktopicon

[Registry]

[Run]
Filename: "{app}\{cm:AppExe}.exe"; Description: "{cm:LaunchProgram,[[NAME]]}"; Flags: nowait postinstall skipifsilent;
