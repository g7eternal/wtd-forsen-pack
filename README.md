# What the Dub?! - Forsen pack
This is a pack of clips of [Sebastian "RolePlayer" Fors (Forsen)](https://twitch.tv/forsen) prepared for use in various party games about dubbing movies.

Supported games are [What the Dub?!](https://store.steampowered.com/app/1495860/What_The_Dub/) and [RiffTrax: The Game](https://store.steampowered.com/app/1707870/RiffTrax_The_Game/).

### This pack features:
+ Over 70 new custom clips to dub!
+ Custom UI videos (intro, round announcements, game end videos)
+ And a whole lot of new SFX to use in your dubs!

> ⚠ Clips in this pack contain strong language :)

## How to install
### Automatic installation
Get the [auto-installer](https://github.com/g7eternal/wtd-forsen-pack/releases/latest/download/wtd-forsen-pack-auto.exe) - it will take care of finding your game and importing all the new clips! The whole process is just a few clicks!
#### Benefits of auto-installer:
+ downloads the latest version of the pack
+ automatically copies all the necessary files into your game folder
+ works with both What The Dub?! and RiffTrax games
+ allows you to select between normal and extended editions of the pack
+ allows you to leave the original video clips - effectively mixing custom and default clips for more content!
+ for streamers - has an option to remove the clips which may be considered as being too "edgy".

When running the installer, you may see a warning about running a file from untrusted source. Since the installer is not digitally signed, your PC will mark it as suspicious. That's completely fine, and you can proceed with installation:

![smartscreen-warning](https://user-images.githubusercontent.com/40625769/149666886-cacdb7a2-6019-4d0e-aa70-e373e508ed73.png)

### Manual installation
1. Choose your flavor, then download and unzip the pack: 
    + Forsen pack - normal edition (~0.9gb): 
        + [GitHub](https://github.com/g7eternal/wtd-forsen-pack/archive/refs/heads/main.zip) 
    + Forsen pack - extended edition (with some bonus clips from [nymn pack](https://github.com/badoge/wtd-nymn-pack), >1gb): 
        + [GitHub](https://github.com/badoge/wtd-nymn-pack/releases/download/v2forsen/wtd-pack-for-forsen.zip)

2. In your Steam library select the **RiffTrax: The Game** or **What the Dub?!**  game, right-click -> _Manage_ -> _Browse local files_

![image](https://user-images.githubusercontent.com/18620902/116490233-e6cafe80-a8a7-11eb-89fd-cb1cd43eca84.png)

3. Depending on the game you have, navigate to the following folder:
    + _WhatTheDub_Data\StreamingAssets_ **OR**
    + _RiffTraxTheGame_Data\StreamingAssets_

4. 
    a. **If you want to keep the original movie clips in the game**, drag and drop the pack files into the _StreamingAssets_ folder

    ![defualt clips and forsen clips](https://user-images.githubusercontent.com/18620902/116491289-973a0200-a8aa-11eb-9475-16b2a87b2b55.gif)

    b. **If you want to play the new clips exclusively**, create a new folder to backup the original movie clips and move the unpacked files into the _StreamingAssets_ folder

    ![forsen clips only](https://user-images.githubusercontent.com/18620902/116491700-8b027480-a8ab-11eb-9c9e-89aeea4a9d90.gif)

5. *Optional*: If you would like to exclude the "risky" clips, consult the [clip list](https://raw.githubusercontent.com/g7eternal/wtd-forsen-pack/main/_installer-src/tos-list.txt) file. It contains instructions as well as the list of files to be removed.

6. All done! Start up the game to confirm: installation has been successful if new game intro is sus.

## How to remove pack
The easiest way: delete the game, then reinstall it.

The proper way:

1. In your Steam library select **What the Dub?!** game, right-click -> _Manage_ -> _Browse local files_

2. Navigate to the folder you copied files into (same as step 3 of "install" section)

3. 
    a. **If you used an automatic installer:**
    * Delete the following folders: _UiVideo, TheEndClips, Subtitles, VideoClips_
    * Find the game in your Steam library, right-click -> *Properties* -> *Local Files* -> *Verify integrity of game files*
    * Steam will restore the original movie clips automatically
    
    b. **If you merged the pack with the original movie clips:**
    * do the same as above
    
    c. **If you replaced the original movie clips with the pack:**

    * Delete the following folders: _UiVideo, TheEndClips, Subtitles, VideoClips_
    * Move the original files from the _backup_ folder back to the _StreamingAssets_ folder

## Technical info
Info on how the game works was taken from [here](https://www.reddit.com/r/RedditAndChill/comments/mtacw3/lets_make_new_what_the_dub_vids_peepopog/).
- Basically you need some MP4 clips in _VideoClips_ folder, and SRT subtitles in _Subtitles_ folder for this to work. The name of MP4 should match with the name of SRT.
- _UiVideo_ folder contains all the intro/intermission/outro clips, simply replace them with any video of your choice.
- At the end of the game a random clip from _TheEndClips_ is chosen and played for the users. Add as many as you like.

## How to contribute
Any way you'd like to:
- if you know how to edit videos, please create a merge request with new files. In order to create a good clip, please follow the guidelines:
  - please keep the submissions "Forsen-related": do not send the clips which are unrelated to Forsen (i.e. other streamers unless Forsen is in the clip)
  - clips in _VideoClips_:
    - MP4 (AVC/AAC); 720p; any bitrate, any fps
    - normalize the volume (peaks at -12db)
    - cutting the audio of the \[insert your dub\] part of the clip is not necessary! (game automatically does that)
    - please try to keep the reasonable size (up to 20mb) and length (10±5 sec)
    - file name should match the pattern of: forsen-\[clip name\].mp4
    - *side note*: it is not necessary to mute the \[dubbed\] part when editing the clip, the game does that automatically for you. You could also _"abuse"_ this in order to make a dirty audio cut under the \[dub\].
  - subtitles in _Subtitles_:
    - generic .srt subtitle files
    - Do NOT use the following symbols mid-sentence: ```: [ ]``` (colon and square brackets)
      - these symbols are reserved for internal use: colon marks the speaker's name; square brackets mark the \[dubbed\] part
    - file name should match the pattern of: forsen-\[clip name\].srt (matching the name of corresponding clip)
  - videos in _UiVideos_:
    - MP4 (AVC/AAC); 1080p; any bitrate, any fps
    - name and length of a clip should match those of the original clip
  - videos in _TheEndClips_:
    - MP4 (AVC/AAC); 720p; any bitrate, any fps
    - please try to keep the reasonable size (up to 20mb) and length (<10 sec)
    - file names are not restricted
- if you don't (or can't) - do not worry! Just contact me:
    - pm me on discord (g7eternal#8037), [twitch](https://twitch.tv/g7eternal) or [twitter](https://twitter.com/g7_eternal)
- *Please note*: these guidelines were written for the clips intended to be used in *What The Dub?!* game. Although *RiffTrax* uses similar structure, which allows this custom pack to be used there too, some of the options above are inaccurate. When making content for *RiffTrax*, be aware of this fact.

## More packs
If you are looking for more custom clips, check out these packs:
- [What the Dub?! - nymn pack](https://github.com/badoge/wtd-nymn-pack)
- [What the Dub?! - GTA pack](https://github.com/g7eternal/wtd-gta-pack)

For more fun, check out these custom packs for other games:
- [Jackbox 6: Forsen Pack](https://github.com/g7eternal/jackbox-forsen-pack-6)
