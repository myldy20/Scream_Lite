; Scream Lite Windows installer

#define MyDisplayName "Scream Lite"
#define MyBinaryName "ScreamLite"
#define MyPublisherName "Scream Lite community fork"
#define MyDataVendor "Cure Audio"

[Setup]
AppName={#MyDisplayName}
AppVersion={#MyVersion}
AppPublisher={#MyPublisherName}
AppPublisherURL=https://github.com/myldy20/Scream_Lite
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DefaultDirName={commonpf64}\{#MyDisplayName}
DefaultGroupName={#MyDisplayName}
LicenseFile="..\LICENSE"
OutputDir="..\dist"
OutputBaseFilename={#MyBinaryName}_v{#MyVersion}
SetupIconFile=_windows_favicon.ico
WizardStyle=dark
WizardImageFile=.\_windows_WizardImageFile.png
WizardImageFileDynamicDark=.\_windows_WizardImageFile.png
WizardBackImageFile=.\_windows_WizardBackImageFile.png
WizardBackImageFileDynamicDark=.\_windows_WizardBackImageFile.png
WizardSmallImageFile=.\_windows_WizardSmallImageFile_DynamicDark.png
WizardSmallImageFileDynamicDark=.\_windows_WizardSmallImageFile_DynamicDark.png
MinVersion=6.2

[Components]
Name: assets; Description: Required assets; Types: full compact custom; Flags: fixed
Name: clap;   Description: CLAP plugin;    Types: full
Name: vst3;   Description: VST3 plugin;    Types: full compact

[Dirs]
Components: vst3; Name: "{commonpf64}\Common Files\VST3\{#MyBinaryName}.vst3"; Attribs: system
Components: clap; Name: "{commonpf64}\Common Files\CLAP"

[InstallDelete]
Components: assets; Type: filesandordirs; Name: "{userappdata}\{#MyDataVendor}\{#MyBinaryName}\cureaudio.png"
Components: assets; Type: filesandordirs; Name: "{userappdata}\{#MyDataVendor}\{#MyBinaryName}\icons.png"
Components: vst3; Type: filesandordirs; Name: "{commonpf64}\Common Files\VST3\{#MyBinaryName}.vst3"
Components: clap; Type: filesandordirs; Name: "{commonpf64}\Common Files\CLAP\{#MyBinaryName}.clap"

[Files]
Components: assets; Source: "..\assets\Tomorrow-SemiBold.ttf"; DestDir: "{userappdata}\{#MyDataVendor}\{#MyBinaryName}"
Components: assets; Source: "..\assets\OFL.txt"; DestDir: "{userappdata}\{#MyDataVendor}\{#MyBinaryName}"; DestName: Tomorrow-OFL.txt
Components: vst3; Source: "..\build\Release\{#MyBinaryName}.vst3"; DestDir: "{commonpf64}\Common Files\VST3"; Flags: recursesubdirs
Components: vst3; Source: "..\assets\desktop.ini.in"; DestDir: "{commonpf64}\Common Files\VST3\{#MyBinaryName}.vst3"; DestName: desktop.ini; Attribs: system hidden
Components: vst3; Source: "..\assets\PlugIn.ico"; DestDir: "{commonpf64}\Common Files\VST3\{#MyBinaryName}.vst3"; Attribs: system hidden
Components: clap; Source: "..\build\Release\{#MyBinaryName}_plugin.dll"; DestDir: "{commonpf64}\Common Files\CLAP"; DestName: {#MyBinaryName}.clap
