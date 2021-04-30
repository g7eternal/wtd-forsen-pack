# What the Dub?! - Forsen pack
This is a pack of clips taken from [Sebastian "RolePlayer" Fors (Forsen)](https://twitch.tv/forsen) to be used in the game called [What the Dub?!](https://store.steampowered.com/app/1495860/What_The_Dub/)

## How to install
1. Download and unpack the files (~500MB): \[ [GitHub](https://github.com/g7eternal/wtd-forsen-pack/archive/refs/heads/main.zip) | [Mirror](https://g7eternal.ru/misc/wtd-forsen-pack.zip) \]

2. In your Steam library select the *What the Dub?!* game, right-click -> Manage -> Browse local files

![image](https://user-images.githubusercontent.com/18620902/116490233-e6cafe80-a8a7-11eb-89fd-cb1cd43eca84.png)

3. Navigate to the following folder: _WhatTheDub_Data\StreamingAssets_

4. 
    a. **If you want to keep the original movie clips in the game**, drag and drop the pack files into the _StreamingAssets_ folder

    ![defualt clips and forsen clips](https://user-images.githubusercontent.com/18620902/116491289-973a0200-a8aa-11eb-9475-16b2a87b2b55.gif)

    b. **If you want to play the the forsen pack only**, create a new folder to backup the original movie clips and move the forsen pack files into the _StreamingAssets_ folder

    ![forsen clips only](https://user-images.githubusercontent.com/18620902/116491700-8b027480-a8ab-11eb-9c9e-89aeea4a9d90.gif)

5. All done! Start up the game to confirm: installation has been successful if intro is changed.

## How to remove pack
1. In your Steam library select *What the Dub?!* game, right-click -> Manage -> Browse local files

2. Navigate to the following folder: _WhatTheDub_Data\StreamingAssets_

3. 
    a. **If you merged the forsen pack with the original movie clips:**

    * Delete the _UiVideo, TheEndClips, Subtitles, VideoClips_ folders
    * Select *What the Dub?!* in your Steam library right-click -> *Properties* -> *Local Files* -> *Verify integrity of game files*
    * Steam will download the original movie clips
    
    b. **If you replaced the original movie clips with the forsen pack:**

    * Delete the _UiVideo, TheEndClips, Subtitles, VideoClips_ folders from the the _StreamingAssets_ folder
    * Move the original files from the _backup_ folder to the _StreamingAssets_ folder

## Technical info
Info on how the game works was taken from [here](https://www.reddit.com/r/RedditAndChill/comments/mtacw3/lets_make_new_what_the_dub_vids_peepopog/).
- Basically you need some MP4 clips in _VideoClips_ folder, and SRT subtitles in _Subtitles_ folder for this to work. The name of MP4 should match with the name of SRT.
- _UiVideo_ folder contains all the intro/intermission/outro clips, simply replace them with any video of your choice.
- At the end of the game a random clip from _TheEndClips_ is chosen and played for the users. Add as many as you like.

## How to contribute
Any way you'd like to:
- pm me on discord (g7eternal#8037), [twitch](https://twitch.tv/g7eternal) or [twitter](https://twitter.com/g7_eternal)
- or create a merge request with new files. If so, please follow the guidelines:
  - please keep the submissions "Forsen-related": do not send the clips which are unrelated to Forsen (i.e. other streamers unless Forsen is in the clip)
  - clips in _VideoClips_:
    - MP4 (AVC/AAC); 720p; any bitrate, any fps
    - normalize the volume (peaks at -12db)
    - please try to keep the reasonable size (up to 20mb) and length (10±5 sec)
    - file name should match the pattern of: forsen-\[clip name\].mp4
  - subtitles in _Subtitles_:
    - generic .srt subtitle files
    - Do NOT use ```:``` (colon) in mid-sentence as it breaks the string in game - use it only to mark the person who is currently speaking!
    - file name should match the pattern of: forsen-\[clip name\].srt (matching the name of corresponding clip)
  - videos in _UiVideos_:
    - MP4 (AVC/AAC); 1080p; any bitrate, any fps
    - name and length of a clip should match those of the original clip
  - videos in _TheEndClips_:
    - MP4 (AVC/AAC); 720p; any bitrate, any fps
    - please try to keep the reasonable size (up to 20mb) and length (<10 sec)
    - file names are not restricted

## More packs
If you are looking for more custom clips, check out these packs:
- [What the Dub?! - nymn pack](https://github.com/badoge/wtd-nymn-pack)
