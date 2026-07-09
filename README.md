# `deltarune-nix`

An unofficial port of [DELTARUNE] for Nix/NixOS systems.

Only `x86_64-linux` and `aarch64-linux` systems are supported for now.

## Source governance & Security notice

DELTARUNE & its game engine, GameMaker, are proprietary. For the sake of user
experience, the packages produced by this flake are not marked as unfree.

Additionally, the game engine depends on OpenSSL 1.0. Support for OpenSSL 1.0
has ended in 2019. However, it does not look like the engine is making any real
use of OpenSSL. Because of this and for user convenience, the packages are not
marked as insecure either.

## Usage

You may launch DELTARUNE using the default package of this flake:

```sh
$ nix run github:MichailiK/deltarune-nix
```

> [!IMPORTANT]
> You will need to download the (unmodified) Windows game files of DELTARUNE
> and add them to the Nix store. **You will be shown a quick guide will be
> if the game files are not present in the Nix store.**
>
> For more thorough instructions, check out the
> [Download DELTARUNE](#download-deltarune) section below.

Additionally, you can also launch individual chapters & individual versions,
including with [libTAS], for creating tool-assisted speedruns/superplays:

```sh
# launch chapter 1 normally
$ nix run github:MichailiK/deltarune-nix#ch1

# launch chapter 1 with libTAS
$ nix run github:MichailiK/deltarune-nix#ch1-libtas

# launch patch v1.00
$ nix run github:MichailiK/deltarune-nix#v1_00

# launch chapter 3 from patch v1.02
$ nix run github:MichailiK/deltarune-nix#v1_02-ch3

# launch chapter 4 from patch v1.01C with libTAS
$ nix run github:MichailiK/deltarune-nix#v1_01C-ch4-libtas
```

For a full listing of the available packages/versions, run
`nix flake show github:MichailiK/deltarune-nix`.

> [!IMPORTANT]
> Launching individual chapters may not allow you to switch chapters. The game
> may exit when trying to.
>
> Make sure you read the [TAS Caveats](#tas-caveats) section below for
> some important information regarding TASing DELTARUNE.

## Download DELTARUNE

### Supported versions

`deltarune-nix` supports all versions of DELTARUNE released on Steam.
Downloading old versions requires the usage of either the Steam console or
[DepotDownloader](https://github.com/SteamRE/DepotDownloader).

The following table lists all DELTARUNE versions `deltarune-nix` supports.

| Version | Chapters | Manifest ID | Build ID | Released |
| ------  | -------- | ----------- | -------- | -------- |
| **[0.0.247](https://steamcommunity.com/games/1671210/announcements/detail/689761349249538291) (LATEST)** | 5 |  `7477373076840518223` | [`24122389`](https://steamdb.info/patchnotes/24122389/) | Jul 9, 2026
| 0.0.244 | 5  | `8959018571141829552` | [`23994151`](https://steamdb.info/patchnotes/23994151/) | Jul 1, 2026
| [0.0.243](https://steamcommunity.com/games/1671210/announcements/detail/689761349249533251) | 5 | `1619878865915573883` | [`23962447`](https://steamdb.info/patchnotes/23962447/) | Jun 29, 2026
| [0.0.242](https://steamcommunity.com/games/1671210/announcements/detail/689761349249533118) | 5 | `5668370237506127426` | [`23942272`](https://steamdb.info/patchnotes/23942272/) | Jun 27, 2026
| [0.0.241](https://steamcommunity.com/games/1671210/announcements/detail/689761349249532439) | 5 | `4986929572195566736` | [`23909557`](https://steamdb.info/patchnotes/23909557/) | Jun 25, 2026
| [0.0.240](https://steamcommunity.com/games/1671210/announcements/detail/689761349249532170) | 5 | `2856471167011435804` | [`23736632`](https://steamdb.info/patchnotes/23736632/) | Jun 24, 2026
| *1.05 (beta)* | 4 | *`8692203871714066779` (deltarune105)* | [`19733487`](https://steamdb.info/patchnotes/19733487/) | Aug 26, 2025
| [1.04](https://steamcommunity.com/games/1671210/announcements/detail/502832157038741680) | 4 | `5291565625263756968` | [`19477244`](https://steamdb.info/patchnotes/19477244/) | Aug 5, 2025
| [1.03](https://steamcommunity.com/games/1671210/announcements/detail/502831523307716617) | 4 | `6956536201257221797` | [`19322285`](https://steamdb.info/patchnotes/19322285/) | Jul 23, 2025
| [1.02](https://steamcommunity.com/games/1671210/announcements/detail/502828986443763623) | 4 | `1738457575886606060` | [`19139485`](https://steamdb.info/patchnotes/19139485/) | Jul 8, 2025
| [1.01C](https://steamcommunity.com/games/1671210/announcements/detail/502827075746400866) | 4 | `3006447521106301427` | [`18791270`](https://steamdb.info/patchnotes/18791270/) | Jun 9, 2025
| [1.01B](https://steamcommunity.com/games/1671210/announcements/detail/502827075746400792) | 4 | `7730842116999772152` | [`18782119`](https://steamdb.info/patchnotes/18782119/) | Jun 8, 2025
| [1.01A](https://steamcommunity.com/games/1671210/announcements/detail/502827075746400245) | 4 | `7360369116571903144` | [`18765027`](https://steamdb.info/patchnotes/18765027/) | Jun 6, 2025
| 1.00 | 4 | `6530852604090871226` | [`18701037`](https://steamdb.info/patchnotes/18701037/) | Jun 4, 2025


### Downloading latest DELTARUNE version

To download DELTARUNE, you will need to be signed in to a
Steam account that
[owns DELTARUNE](https://store.steampowered.com/app/1671210/DELTARUNE/).

> [!NOTE]
>
> - These instructions are applicable to **Windows and Linux** systems only.
>   macOS users must use the "[Downloading other versions](#downloading-other-versions)" 
>   method below.
> - Check the [table above](#supported-versions) to see if `deltarune-nix`
>   supports the latest version of DELTARUNE. If there is a newer version, then
>   it is not supported by `deltarune-nix` at the moment.
>   - If this is the case, please [open an issue](https://github.com/MichailiK/deltarune-nix/issues).
>   - In the meantime, you are able to [download the previous version](#downloading-other-versions).

1. Start downloading DELTARUNE using the Steam client.
2. Wait for the download to complete. The progess is displayed via the
   Download Manager at the bottom of the Steam client.
3. Once complete, browse to the directory of the game files.
   - At your Steam library, right click **DELTARUNE -> Properties... -> Installed
     Files -> Browse...**
   - Your file explorer should now open, showing the directory of DELTARUNE's
     game files. Copy the path to this directory.
4. Add the directory to the Nix store: `nix store add-path --name deltarune GAME_FILES_PATH`
   (replace GAME_FILES_PATH)

For example, on a Linux system with the default install location:

```sh
$ nix store add-path --name deltarune ~/.local/share/Steam/steamapps/common/DELTARUNE
```

On WSL systems, you are likely using the Windows Steam client to download DELTARUNE.
You can [access your Windows filesystem via `/mnt`](<https://learn.microsoft.com/en-us/windows/wsl/wsl-config#what-is-drvfs>)
within WSL to add the DELTARUNE game files to the Nix store. For example,
with the default Steam install location:

```sh
$ nix store add-path --name deltarune "/mnt/c/Program Files (x86)/Steam/steamapps/common/DELTARUNE"
```

> [!IMPORTANT]
> Make sure that there are no mods or other files in your DELTARUNE installation.
> `deltarune-nix` cannot recognize modified game files of DELTARUNE.
>
> If you are having trouble making `deltarune-nix` recognize your DELTARUNE
> installation, please consider re-downloading DELTARUNE game files using the
> "[Downloading other versions](#downloading-other-versions)" method below.

### Downloading other versions


#### Steam client (old versions)

The Steam console allows downloading old versions of DELTARUNE using its
manifest ID. 

1. Reveal the Steam console. To do this, you can either:
   - Open `steam://open/console` in a browser to reveal the console tab & switch to it.
   - Quit Steam & launch it again with the `-console` argument.
2. In the console's text field, paste
   `download_depot 1671210 1671212 $MANIFEST_ID` (replace `$MANIFEST_ID`)
3. Hit enter. You should see the log message
   `Downloading depot 1671212 (123 files, 456 MB) ...`
   appear after a few seconds.
4. Wait for the download to finish.
   Once the download is finished, you will see:
   `Depot download complete : "/home/USER/.local/share/Steam/ubuntu12_32\steamapps\content\app_1671210\depot_1671212" (manifest 1234567890123456)"`
   logged to the console. Take note of the directory path.
5. Add the files to the Nix store, for example:

   ```sh
   $ nix store add-path --name deltarune ~/.local/share/Steam/ubuntu12_32/steamapps/content/app_1671210/depot_1671212
   ```

   (For WSL users, the default path is `"/mnt/c/Program Files (x86)/Steam/steamapps/content/app_1671210/depot_1671212"`)

#### Steam client (beta versions)

Beta versions can be switched to in the Steam UI. At your Steam library,
right click **DELTARUNE -> Properties... -> Game Versions & Betas**. Select the
beta you would like to install.

Changing versions is treated as a game update & will automatically download the
selected version. Wait for the download/update to complete.

Once complete, you can add the directory to the Nix store using
`nix store add-path --name deltarune $GAME_FILES_PATH` (replace `$GAME_FILES_PATH`).


#### DepotDownloader

[DepotDownloader](https://github.com/SteamRE/DepotDownloader) is a third-party
CLI utility that allows downloading Steam games/depots. It allows
downloading old & beta versions of DELTARUNE using its manifest ID.


Use `depotdownloader -app 1671210 -depot 1671212 -manifest $MANIFEST_ID` (replace `$MANIFEST_ID`)
alongside with your Steam credentials (`-username foobar`).

Once done:
1. Delete the `.DepotDownloader` directory inside the game files
   (`rm -r ./depots/1671212/$BUILD_ID/.DepotDownloader`)

   > The `.DepotDownloader` directory MUST NOT be present in the game files.
   > Otherwise Nix will calculate a different hash from what `deltarune-nix`
   > requires & it will fail to find the game files.

2. Change the permissions of every file to include the executable bit
   (`chmod -R +x ./depots/1671212/$BUILD_ID`)

   > The executable bit MUST be set, as Nix NAR hashes consider the executable bit.
   > Since both Steam & WSL set the executable bit on every file & directory,
   > this project has opted into to set it for the asset NAR hash as well.  

3. Add the game files to the Nix store using
   `nix store add-path --name deltarune ./depots/1671212/$BUILD_ID` (replace $BUILD_ID).

Note for beta versions, you need to add another argument, `-beta $BRANCH_NAME`.
The branch name is found in the table in parentheses, next to the manifest ID.

## Caveats

- When loading saves for any of the chapters, you may notice that the
  music/audio is gone, to fix this:
  - go to your save at `~/.config/DELTARUNE/`
  - edit line 569/570 and change both values from `.` to `,`, or vice-versa
- Chapter 5 intro video only plays sound. See [this issue](https://github.com/MichailiK/deltarune-nix/issues/5)

### TAS Caveats

- You must enable Settings -> Runtime -> clock_gettime() monotonic,
  otherwise the game will softlock.
- You should set the FPS target to 30, as DELTARUNE itself is locked to 30 FPS.
- libTAS does not support Wayland. If you are running a Wayland session, ensure
  you enabled Xwayland in your desktop environment, and ensure both libTAS
  as well as the game are running through X11.
  - The `ch1-libtas`, `ch2-libtas` ... packages in this flake pass
    `QT_QPA_PLATFORM=xcb` into libTAS to ensure it runs through X11.
    DELTARUNE can currently only run through X11.
- Chapter switching is not possible with libTAS. When switching chapters,
  the game actually launches a new process of itself & quits the old one.
  libTAS is not designed to handle this scenario.

## Q&A

### Why am I building OpenSSL 1.0.2u?

The YoYo Games Linux Runner, which is responsible for running GameMaker games
like DELTARUNE, depends on OpenSSL 1.0, which has been end-of-life since 2019.
Insecure packages are not built for cache.nixos.org, and thus must instead
be built locally.

### Why am I building curl?

The YoYo Games Runner depends on
[Debian-specific symbol versioning of `libcurl3-gnutls`](https://bugs.debian.org/1020780).
The patches to accomedate this versioning require curl to be rebuilt locally.

### Why am I building libTAS? It's in nixpkgs!

libTAS is packaged in nixpkgs, however, as of writing, it is broken & doesnt
build for some reason. Once the upstream nixpkgs gets fixed, the libTAS packages
here will point to nixpkgs again.


## Other info

### Runtimes

There are multiple Linux runtimes for GameMaker games. `deltarune-nix`
currently implements two:

#### DELTARUNNER

[DELTARUNNER] is a modified GMS LTS runner that designed for DELTARUNE & its usage
of `game_switch`.

It supports both x86_64 and AArch64 Linux systems, and is the preferred runtime
for every DELTARUNE version exposed on this flake.

#### deltaport

[deltaport] is a project for porting DELTARUNE version 1.01C to Linux with an
(unmodified?) GMS LTS runner. It applies xdelta patches to the game files to
faciliate a makeshift `game_switch` implementation by writing a file which a
bash script watches for to faciliate the game switch.

It is only compatible with x86_64 systems and version 1.01C. It is available
under the `+deltaport` suffix in this flake's packages.

### Special thanks

Special thanks to the [DELTARUNNER] and [deltaport] maintainers for making this
Nix/NixOS port possible in the first place!

This is a sister project of [yoyo-games-runner-nix], a Nix flake for
porting the GameMaker Linux runtimes to Nix/NixOS systems.

[DELTARUNE]: https://deltarune.com/
[DELTARUNNER]: https://github.com/InvoxiPlayGames/DELTARUNNER
[deltaport]: https://github.com/pungus7/deltaport
[yoyo-games-runner-nix]: https://github.com/MichailiK/yoyo-games-runner-nix
[libTAS]: https://github.com/clementgallet/libTAS
