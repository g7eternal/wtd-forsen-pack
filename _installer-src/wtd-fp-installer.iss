#define MyAppName "What The Dub: Forsen Pack"
#define MyAppVersion "1.1"
#define MyAppPublisher "@G7_Eternal"
#define MyAppURL "https://github.com/g7eternal/wtd-forsen-pack"
#define MyAppSourceURL "https://github.com/g7eternal/wtd-forsen-pack/archive/refs/heads/main.zip"
;#define MyAppSourceURL "http://localhost:2234/wtd-forsen-pack-main.zip"
#define MyAppExtensionURL "https://github.com/g7eternal/wtd-forsen-pack/releases/download/dummy_tag_1/wtd-fp-extension.zip"
#define MyAppGtaSourceURL "https://github.com/g7eternal/wtd-gta-pack/archive/refs/heads/master.zip"

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
DefaultDirName={autopf}
DisableDirPage=yes
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
Name: "full"; Description: "All the custom clips!"
Name: "forsen"; Description: "Forsen Pack"
Name: "extended"; Description: "Forsen Pack: Extended edition"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: Forsen_pack; Description: "What The Dub - Forsen pack: Clips from twitch.tv/forsen and friends; clip contents are mostly Forsen-related!"; Types: full forsen extended custom; Flags: fixed
Name: Extension_pack; Description: "Extension pack: [Yoinked from Nymn's pack] Various funny clips to increase your gameplay variety! Contents: Gachi, Wakaliwood, generic well-known clips, etc. (clips are stream-friendly)"; Types: full extended
Name: Gta_pack; Description: "GTA pack: Clips of cutscenes from GTA series. Hilarious stream-friendly setups for your dubs, and more custom sounds to choose from!"; Types: full custom

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: pack_exclusive; Description: "Install this pack EXCLUSIVELY: all existing clips will be removed from the game, you will be playing only with clips from this pack"; GroupDescription: "Select installation variant:"; Components: Forsen_pack; Flags: exclusive
Name: pack_mixed; Description: "MIX UP all the clips: Clips from this pack will be added into the clip pool and mixed up with all the existing clips"; GroupDescription: "Select installation variant:"; Components: Forsen_pack; Flags: exclusive unchecked
Name: tos_generic; Description: "Normal mode: clips are not filtered"; GroupDescription: "Twitch TOS compliance:"; Components: Forsen_pack; Flags: exclusive
Name: tos_strict; Description: "Strict mode: game will NOT feature clips that may be considered as borderline TOS-breaking or too edgy in general"; GroupDescription: "Twitch TOS compliance:"; Components: Forsen_pack; Flags: exclusive unchecked

[Files]
Source: "{tmp}\wtd-forsen-pack-main\*"; DestDir: "{code:GetInstallPath|}StreamingAssets"; Components: Forsen_pack; Flags: ignoreversion recursesubdirs createallsubdirs external
Source: "{tmp}\wtd-fp-extension\*"; DestDir: "{code:GetInstallPath|}StreamingAssets"; Components: Extension_pack; Flags: ignoreversion recursesubdirs createallsubdirs external
Source: "{tmp}\wtd-gta-pack-master\*"; DestDir: "{code:GetInstallPath|}StreamingAssets"; Components: Gta_pack; Flags: ignoreversion recursesubdirs createallsubdirs external
; NOTE: Don't use "Flags: ignoreversion" on any shared system files


[Code]
const Steam32RegPath = 'SOFTWARE\Valve\Steam';
      Steam64RegPath = 'SOFTWARE\Wow6432Node\Valve\Steam';
      SteamLibPathDiv= '"'#9#9'"';
      // external resources
      WTD_Assets = 'StreamingAssets\';
      WTD_bkpPrefix  = 'mbackup_';
      WTD_ZipContainer= 'wtd-forsen-pack-source.zip';
      WTD_ZipExContainer= 'wtd-fp-extension.zip';
      WTD_GtaContainer= 'wtd-gta-pack-source.zip';
      // shell flags (for unzipper)
      SHCONTCH_NOPROGRESSBOX = 0; // use 4 to disable progressbox
      SHCONTCH_RESPONDYESTOALL = 16;
      // Twitch TOS clips removal
      TOS_ListFile = '_installer-src\tos-list.txt';
      TOS_ClipLocation = 'VideoClips';
      TOS_ClipFormat = '.mp4';

var SteamPath: string;
    SteamLibraryList: TArrayOfString;
    WhatTheDubPath: string;
    DownloadPage: TDownloadWizardPage;
    ChooseGamePage: TInputOptionWizardPage;
    ChooseDirPage: TInputDirWizardPage;

function GetChosenGamePath(): string;
begin
  case ChooseGamePage.SelectedValueIndex of
    0: Result := 'WhatTheDub\';
    1: Result := 'RiffTraxTheGame\';
    else Result := '';
  end;
end;

function GetChosenGameDataPath(): string;
begin
  case ChooseGamePage.SelectedValueIndex of
    0: Result := 'WhatTheDub_Data\';
    1: Result := 'RiffTraxTheGame_Data\';
    else Result := '';
  end;
end;

function GetInstallPath(ObsoleteParam: string): string;
begin
  Result := AddBackSlash(ChooseDirPage.Values[0])+GetChosenGameDataPath();
end;

function GetWTDPath(ObsoleteParam: string): string;
var i: Integer;
    j: Integer;
    libCount: Integer;
    subpos: Integer;
    tryThisPath: String;
    chosenGame: String;
begin
  WhatTheDubPath := '';
  try
    chosenGame := GetChosenGamePath();
  except
    Log('Failed to detect chosen game: ' + AddPeriod(GetExceptionMessage));
  end;
  if length(chosenGame) < 1 then begin
    Log('User did not select the game! (yet?)');
    Result := '';
    Exit;
  end;
  Log('User selected game: '+chosenGame);
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
    // let's try to find the installed game
    for i := 0 to Length(SteamLibraryList)-1 do begin
      if DirExists(AddBackSlash(SteamLibraryList[i])) then begin
        tryThisPath := AddBackSlash(SteamLibraryList[i])+'SteamApps\common\'+chosenGame;
        if DirExists(tryThisPath)
          then begin
            Log('Found selected game at: '+tryThisPath);
            WhatTheDubPath := tryThisPath;
          end;
      end;
    end;
  end else Log('Failed to read "SteamApps\libraryfolders.vdf"!');
  Result := WhatTheDubPath;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var AnyChecked: Boolean;
  I: Integer;
begin
  Case CurPageId of
    ChooseGamePage.ID: begin
      for I := 0 to ChooseGamePage.CheckListBox.Items.Count - 1 do
        begin
          if ChooseGamePage.CheckListBox.Checked[I] then
            AnyChecked := True;
        end;
        if (not(AnyChecked)) then MsgBox(
          'Choose a game! Any game!'#13#10#13#10'If you don''t have a game, you can''t enjoy this pack!',
          mbError, mb_OK
        );
        ChooseDirPage.Values[0] := GetWTDPath('');
        Result := AnyChecked;
    end;
    ChooseDirPage.ID: begin
      if not(DirExists(AddBackSlash(ChooseDirPage.Values[0])+GetChosenGameDataPath()))
        then begin
          MsgBox('Folder "'+ChooseDirPage.Values[0]+' does not contain the chosen game!'#13#10
            'You need to select a valid folder within Steam apps!', mbCriticalError, mb_OK);
          Result := false;
        end else Result := true;
    end;
    wpReady: begin
      DownloadPage.Clear;
      if (WizardIsComponentSelected('Forsen_pack'))
        then DownloadPage.Add(ExpandConstant('{#MyAppSourceURL}'), WTD_ZipContainer, '');
      if (WizardIsComponentSelected('Extension_pack'))
        then DownloadPage.Add(ExpandConstant('{#MyAppExtensionURL}'), WTD_ZipExContainer, '');
      if (WizardIsComponentSelected('Gta_pack'))
        then DownloadPage.Add(ExpandConstant('{#MyAppGtaSourceURL}'), WTD_GtaContainer, '');
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

procedure InitializeWizard;
begin
  // create a download page to fetch git contents
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
  // create a page to choose between WTD and RiffTrax
  ChooseGamePage := CreateInputOptionPage(wpWelcome,
    'Choose your game', 'Which game would you like to install this pack onto?',
    'This pack supports multiple games. Choose the one you have installed, then click Next.',
    True, False);
  ChooseGamePage.Add('What the Dub?!');
  ChooseGamePage.Add('RiffTrax: The Game (new! - limited support)');
  // wtd is the default option
  ChooseGamePage.Values[0] := True;
  // create a custom "select directory" page
  ChooseDirPage := CreateInputDirPage(ChooseGamePage.ID,
  'Select game location', 'Where is your chosen game located?',
  'We attempted to find the game you''ve chosen on your PC.'#13#10'The custom pack will be installed into this folder.'#13#10#13#10 +
  'Please confirm the location, then click Next to continue.'#13#10'If you would like to select a different folder, click Browse.',
  False, '');
  ChooseDirPage.Add('');
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
      if (WizardIsComponentSelected('Forsen_pack'))
        then begin
        Log(Format('[main] Unzipping files into %s', [targetPath]));
          UnZip(
            AddBackSlash(ExpandConstant('{tmp}')) + WTD_ZipContainer ,
            targetPath
          );
        end;
      if (WizardIsComponentSelected('Extension_pack'))
        then begin
          Log(Format('[extension pack] Unzipping files into %s', [targetPath]));
          UnZip(
            AddBackSlash(ExpandConstant('{tmp}')) + WTD_ZipExContainer ,
            targetPath
          );
        end;
      if (WizardIsComponentSelected('Gta_pack'))
        then begin
          Log(Format('[GTA pack] Unzipping files into %s', [targetPath]));
          UnZip(
            AddBackSlash(ExpandConstant('{tmp}')) + WTD_GtaContainer ,
            targetPath
          );
        end;
      // touch backup and game folders - and make the backups
      Page.Description := 'Backing up existing files...';
      try
        fpath := AddBackSlash(ChooseDirPage.Values[0])+GetChosenGameDataPath()+WTD_Assets;
        Log('Unpacking files to: '+fpath);
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
      targetPath := GetChosenGameDataPath() + WTD_Assets;
      // TOS: remove clips in the cmonBruh list
      if (WizardIsTaskSelected('tos_strict'))
      then begin
        if (LoadStringsFromFile(
          AddBackSlash(ChooseDirPage.Values[0]) + targetPath + TOS_ListFile,
          TOS_List
        )) then begin
          for i := 0 to GetArrayLength(TOS_List)-1 do begin
            TOS_Item := TOS_List[i];
            if (Length(Trim(TOS_Item)) > 0) and (not WildcardMatch(Trim(TOS_Item), '#*')) 
            then begin
              TOS_ClipFile := AddBackSlash(ChooseDirPage.Values[0]) + AddBackSlash(targetPath + TOS_ClipLocation) + TOS_Item;
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
            'The game will still run fine. But... just be extra careful, I guess. And don''t say you haven''t been warned.',
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

