#define MyAppName "What The Dub: Forsen Pack"
#define MyAppVersion "1.0"
#define MyAppPublisher "@G7_Eternal"
#define MyAppURL "https://github.com/g7eternal/wtd-forsen-pack"
#define MyAppSourceURL "https://github.com/g7eternal/wtd-forsen-pack/archive/refs/heads/main.zip"
#define MyAppExtensionURL "https://github.com/g7eternal/wtd-forsen-pack/releases/download/dummy_tag_1/wtd-fp-extension.zip"

[Setup]
; for digital signature define signing tool in compiler as:
; ms-sign-tool=signtool.exe sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /f "/path/to/certificate.pfx" /p cert-password /a $p
;SignTool=ms-sign-tool $f
AppId={{5264ACC4-3CD3-4615-AF89-64C6DC33F0CC}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
CreateAppDir=yes
DefaultDirName={code:GetWTDPath|}
DirExistsWarning=no
; User will have to remove the pack manually! 
Uninstallable=no
PrivilegesRequired=lowest
OutputDir=target
OutputBaseFilename=wtd-forsen-pack-auto
SetupIconFile=favicon.ico
Compression=lzma
SolidCompression=yes
DisableWelcomePage=no
WizardStyle=modern
WizardImageFile=sidebar.bmp
WizardSmallImageFile=logo.bmp
; since external files are not counted towards size requirement calc, we override this:
ExtraDiskSpaceRequired=1234567890

[Types]
Name: "full"; Description: "Forsen Pack"
Name: "extended"; Description: "Forsen Pack: Extended edition"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: Forsen_pack; Description: "What The Dub - Forsen pack: Clips from twitch.tv/forsen and friends; clip contents are mostly Forsen-related!"; Types: full extended custom; Flags: fixed
Name: Extension_pack; Description: "Extended pack: [Yoinked from Nymn's pack] Various funny clips to increase your gameplay variety! Contents: Gachi, Wakaliwood, generic well-known clips, etc. (clips are stream-friendly)"; Types: extended

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
;Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: pack_exclusive; Description: "Install Forsen pack EXCLUSIVELY: all existing clips will be removed from the game, you will be playing only with clips from this pack"; GroupDescription: "Select installation variant:"; Components: Forsen_pack; Flags: exclusive
Name: pack_mixed; Description: "MIX UP all the clips: Clips from Forsen pack will be added into the clip pool and mixed up with all the existing clips"; GroupDescription: "Select installation variant:"; Components: Forsen_pack; Flags: exclusive unchecked
Name: tos_generic; Description: "Normal mode: clips are not filtered"; GroupDescription: "Twitch TOS compliance:"; Components: Forsen_pack; Flags: exclusive
Name: tos_strict; Description: "Strict mode: game will NOT feature clips that may be considered as borderline TOS-breaking or too edgy in general"; GroupDescription: "Twitch TOS compliance:"; Components: Forsen_pack; Flags: exclusive unchecked

[Files]
Source: "{tmp}\wtd-forsen-pack-main\*"; DestDir: "{app}\WhatTheDub_Data\StreamingAssets"; Components: Forsen_pack; Flags: ignoreversion recursesubdirs createallsubdirs external
Source: "{tmp}\wtd-fp-extension\*"; DestDir: "{app}\WhatTheDub_Data\StreamingAssets"; Components: Extension_pack; Flags: ignoreversion recursesubdirs createallsubdirs external
; NOTE: Don't use "Flags: ignoreversion" on any shared system files


[Code]
const Steam32RegPath = 'SOFTWARE\Valve\Steam';
      Steam64RegPath = 'SOFTWARE\Wow6432Node\Valve\Steam';
      SteamLibPathDiv= '"'#9#9'"';
      WTD_MediaPath  = 'WhatTheDub_Data\StreamingAssets\';
      WTD_bkpPrefix  = 'mbackup_';
      WTD_ZipContainer= 'wtd-forsen-pack-source.zip';
      WTD_ZipExContainer= 'wtd-fp-extension.zip';
      // shell flags (for unzipper)
      SHCONTCH_NOPROGRESSBOX = 0; // use 4 to disable progressbox
      SHCONTCH_RESPONDYESTOALL = 16;
      // Twitch TOS clips removal
      TOS_ListFile = 'WhatTheDub_Data\StreamingAssets\_installer-src\tos-list.txt';
      TOS_ClipLocation = 'WhatTheDub_Data\StreamingAssets\VideoClips';
      TOS_ClipFormat = '.mp4';

var SteamPath: string;
    SteamLibraryList: TArrayOfString;
    WhatTheDubPath: string;
    DownloadPage: TDownloadWizardPage;

function GetWTDPath(ObsoleteParam: string): string;
var i: Integer;
    j: Integer;
    libCount: Integer;
    subpos: Integer;
    tryThisPath: String;
begin
  WhatTheDubPath := '';
  if //find Steam install path from registry
    not(RegQueryStringValue(HKEY_LOCAL_MACHINE, Steam32RegPath, 'InstallPath', SteamPath))
    and 
    not(RegQueryStringValue(HKEY_LOCAL_MACHINE, Steam64RegPath, 'InstallPath', SteamPath))
  then begin
    Log('Failed to find Steam install path in Registry!');
    SteamPath := '';
  end else Log('Found Steam install path: '+SteamPath);
  if (LoadStringsFromFile(AddBackslash(SteamPath) + 'SteamApps\libraryfolders.vdf', SteamLibraryList))
  then begin // find Steam libraries present on PC
    libCount := 1;
    for i := 0 to Length(SteamLibraryList)-1 do begin
      subpos := Pos(SteamLibPathDiv, SteamLibraryList[i]);
      if subpos > 0
        then begin
          SteamLibraryList[i] := Copy(SteamLibraryList[i], subpos+Length(SteamLibPathDiv), Length(SteamLibraryList[i]));
          SteamLibraryList[i] := Copy(SteamLibraryList[i], 0, Length(SteamLibraryList[i])-1); // remove trailing quotes
          libCount := libCount + 1;
          j := 1;
          while (j < Length(SteamLibraryList[i])) do begin // replace double backslash into single backslash
            if (SteamLibraryList[i][j] = '\') and (SteamLibraryList[i][j+1] = '\')
              then begin
                Delete(SteamLibraryList[i], j, 1);
                j := j - 1;
              end;
            j := j + 1;
          end;
        end else SteamLibraryList[i] := '';
    end;
    SetArrayLength(SteamLibraryList, GetArrayLength(SteamLibraryList) + 1);
    SteamLibraryList[High(SteamLibraryList)] := SteamPath;
    Log('Found 1+'+IntToStr(libCount-3)+' Steam library folder variants');
    // let's try to find the installed WhatTheDub game
    for i := 0 to Length(SteamLibraryList)-1 do begin
      if DirExists(AddBackSlash(SteamLibraryList[i])) then begin
        tryThisPath := AddBackSlash(SteamLibraryList[i])+'SteamApps\common\WhatTheDub\';
        if DirExists(tryThisPath)
          then begin
            Log('Found WhatTheDub game at: '+tryThisPath);
            WhatTheDubPath := tryThisPath;
          end;
      end;
    end;
  end else Log('Failed to read "SteamApps\libraryfolders.vdf"!');
  Result := WhatTheDubPath;
end;

function InitializeSetup: Boolean;
begin
  if Length(GetWTDPath('')) < 1
  then Result := (MsgBox('We couldn''t find "What The Dub" game on your PC automatically!'#13#10#13#10
          'You need to install Steam, then install the base game in order to enjoy the Forsen pack!'#13#10
          'Do you want to continue installation?',
          mbError, MB_YESNO) = IDYES)
  else Result := True;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Case CurPageId of
    wpSelectDir: begin
      if not(DirExists(AddBackSlash(ExpandConstant('{app}'))+'WhatTheDub_Data'))
        then begin
          MsgBox('Folder "'+ExpandConstant('{app}')+' does not contain "What The Dub" game!'#13#10
            'You need to select a valid folder within Steam apps!', mbCriticalError, mb_OK);
          Result := false;
        end else Result := true;
    end;
    wpReady: begin
      DownloadPage.Clear;
      DownloadPage.Add(ExpandConstant('{#MyAppSourceURL}'), WTD_ZipContainer, '');
      if (WizardIsComponentSelected('Extension_pack'))
        then DownloadPage.Add(ExpandConstant('{#MyAppExtensionURL}'), WTD_ZipExContainer, '');
      DownloadPage.Show;
      try
        try
          DownloadPage.Download; // This downloads the files to {tmp}
          Result := True;
        except
          if DownloadPage.AbortedByUser then begin
            //SuppressibleMsgBox('Download has been cancelled!', mbInformation, MB_OK, IDOK);
            Log('Aborted by user.');
          end else begin
            SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
          end;
          Result := False;
        end;
      finally
        DownloadPage.Hide;
      end;
    end;
    else Result := true;
  end;
end;


// ONLINE DOWNLOADER STUFF

// https://stackoverflow.com/questions/6065364
procedure UnZip(ZipPath, TargetPath: string);

var
  Shell: Variant;
  ZipFile: Variant;
  TargetFolder: Variant;
begin
  Shell := CreateOleObject('Shell.Application');

  ZipFile := Shell.NameSpace(ZipPath);
  if VarIsClear(ZipFile) then
    RaiseException(Format('ZIP file "%s" does not exist or cannot be opened', [ZipPath]));

  ForceDirectories(TargetPath);
  TargetFolder := Shell.NameSpace(TargetPath);
  if VarIsClear(TargetFolder) then
    RaiseException(Format('Target path "%s" could not be created', [TargetPath]));

  TargetFolder.CopyHere(ZipFile.Items, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
end;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then begin
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  end;
  Result := True;
end;

procedure InitializeWizard; // create a download page to fetch git contents
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var fpath: String;
    bkpfolder: String;
    targetPath: String;
    Page: TWizardPage;
    TOS_List: TArrayOfString;
    TOS_Item: String;
    TOS_ClipFile: String;
    i: Integer; // is there really no way to iterate over array without index? pepeW
begin
  Case CurStep of
    ssInstall: begin
      Log('Starting pre-install work...');
      Page := PageFromID(WizardForm.CurPageID);
      // unzip contents into temp location
      Page.Description := 'Unpacking contents... (may take a while!)';
      targetPath := ExpandConstant('{tmp}');
      Log(Format('Unzipping files into %s', [targetPath]));
      UnZip(
        AddBackSlash(ExpandConstant('{tmp}')) + WTD_ZipContainer ,
        targetPath
      );
      if (WizardIsComponentSelected('Extension_pack'))
        then begin
          Log(Format('[extension pack] Unzipping files into %s', [targetPath]));
          UnZip(
            AddBackSlash(ExpandConstant('{tmp}')) + WTD_ZipExContainer ,
            targetPath
          );
        end;
      // touch backup and game folders - and make the backups
      Page.Description := 'Backing up existing files...';
      try
        fpath := AddBackSlash(ExpandConstant('{app}'))+WTD_MediaPath;
        if not(ForceDirectories(fpath))
          then RaiseException('Cannot touch folder path! - '+fpath);
        bkpfolder := GetMD5OfString(GetDateTimeString('ddddd tt',#0,#0))+'\';
        if not(ForceDirectories(fpath+WTD_bkpPrefix+bkpfolder))
          then RaiseException('Cannot touch backup path! - '+fpath);
        // create backups of game files
        RenameFile(fpath+'TheEndClips', fpath+WTD_bkpPrefix+bkpfolder+'TheEndClips');
        if not(WizardIsTaskSelected('pack_mixed')) then
          RenameFile(fpath+'VideoClips', fpath+WTD_bkpPrefix+bkpfolder+'VideoClips');
      except
        ShowExceptionMessage;
      end;
      Log('Pre-install work ended. We will now copy the files.');
      Page.Description := 'Installing pack contents...';
      WizardForm.ProgressGauge.Style := npbstMarquee;
    end;
    ssPostInstall: begin
      // TOS: remove clips in the cmonBruh list
      if (WizardIsTaskSelected('tos_strict'))
      then begin
        if (LoadStringsFromFile(
          AddBackSlash(ExpandConstant('{app}')) + TOS_ListFile,
          TOS_List
        )) then begin
          for i := 0 to GetArrayLength(TOS_List)-1 do begin
            TOS_Item := TOS_List[i];
            if (Length(Trim(TOS_Item)) > 0) and (not WildcardMatch(Trim(TOS_Item), '#*')) 
            then begin
              TOS_ClipFile := AddBackSlash(ExpandConstant('{app}')) + AddBackSlash(TOS_ClipLocation) + TOS_Item;
              if not WildcardMatch(TOS_ClipFile, '*'+TOS_ClipFormat) then TOS_ClipFile := TOS_ClipFile + TOS_ClipFormat;
              if (DeleteFile(TOS_ClipFile))
                then Log(Format('[TOS] Clip has been removed: %s', [TOS_ClipFile]))
                else Log(Format('[TOS] Failed to remove a clip: %s', [TOS_ClipFile]));
            end;
          end;
        end else begin
          Log(Format('[TOS] Failed to acquire the list of edgy clips at %s; clips will not be filtered!', [TOS_ListFile]));
          MsgBox('Heads up! We have a slight problem.'#13#10#13#10
            'Installer failed to read the list of TOS-unfriendly clips, therefore the clips have not been filtered.'#13#10#13#10
            'The game will still run fine, just be careful with streaming on Twitch. And don''t say you haven''t been warned.',
            mbError, MB_OK);
        end;
      end;
      // all done, tell user to relax
      MsgBox('WTD: Forsen pack has been installed!'#13#10#13#10
        'Should you ever want to remove the pack, you are better off re-installing the game. (I''m too lazy to make a proper uninstaller LULE)'#13#10
        'Or you could remove the pack files manually: follow the instructions at our GitHub page on how to do it, original game files have been backed up for you.'#13#10#13#10
        'Anyways... Thank you for using our hypermodern install system! Hope you have some fun with the pack!',
        mbInformation, MB_OK);
      end;
  end;
end;

