# `deltarune-nix`

An unofficial port of [DELTARUNE] for Nix/NixOS systems using the
[deltaport] and [yoyo-games-runner-nix] projects.

Only `x86_64-linux` systems are supported for now.

This port is made for (and is only compatible with) DELTARUNE v1.01C.
The Windows game files must be present in the Nix store to build the port.

## Download DELTARUNE

To download DELTARUNE v1.01C for Windows, you will need to be signed in to a
Steam account that [owns DELTARUNE](https://store.steampowered.com/app/1671210/DELTARUNE/).

There are two methods of downloading a copy of DELTARUNE v1.01C:

### Steam client

1. Open `steam://open/console` to reveal the console
   tab & switch to it.
2. In the console's text field, paste
   `download_depot 1671210 1671212 3006447521106301427`[^1]
   and hit enter. You should see the log message
   `Downloading depot 1671212 (397 files, 366 MB) ...`
   appear after a few seconds.
3. Wait for the download to finish.
   Once the download is finished, you will see:
   `Depot download complete : "/home/USER/.local/share/Steam/ubuntu12_32\steamapps\content\app_1671210\depot_1671212" (manifest 3006447521106301427)"`
   logged to console.
   You will find the game files in the stated directory.
     
> [!IMPORTANT]
> A portion of the path in the Steam console uses backslashes.
> Replace them with forward slashes.

### [DepotDownloader](https://github.com/SteamRE/DepotDownloader)

Use `depotdownloader -app 1671210 -depot 1671212 -manifest 3006447521106301427`
alongside with your Steam credentials.

## Add to Nix store

Once you have obtained a copy, add it to the Nix store using
`nix store add-path --name deltarune <directory>`. For example,
if you downloaded the game using the Steam client:

```sh
$ nix store add-path --name deltarune ~/.local/share/Steam/ubuntu12_32/steamapps/content/app_1671210/depot_1671212
```

## Usage

You may launch DELTARUNE using the default package of this flake:

```sh
$ NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_INSECURE=1 nix run --impure github:MichailiK/deltarune-nix
```

Or you may launch individual chapters, including with [libTAS] for creating
Tool-assisted speedruns/superplays:

```sh
# launch chapter 1 normally
$ ... nix run --impure github:MichailiK/deltarune-nix#ch1
# launch chapter 1 with libTAS
$ ... nix run --impure github:MichailiK/deltarune-nix#ch1-libtas
```

> [!IMPORTANT]
> Launching individual chapters will not allow you to switch chapters. The game
> will exit when trying to.
>
> Make sure you read the [TAS Caveats](#tas-caveats) section below for
> some important information regarding TASing DELTARUNE.

## Caveats

- When loading saves for any of the chapters, you may notice that the
  music/audio is gone, to fix this:
  - go to your save at `~/.config/DELTARUNE/`
  - edit line 569/570 and change both values from `.` to `,`, or vice-versa

### TAS Caveats

- You must enable Settings -> Runtime -> clock_gettime() monotonic,
  otherwise the game will softlock.
- You should set the FPS target to 30 when recording TAS's.
- libTAS does not support Wayland. If you are running a Wayland session, ensure
  you enabled Xwayland in your desktop environment, and ensure both libTAS
  as well as the game are running through X11.
  - The `ch1-libtas`, `ch2-libtas` ... packages in this flake pass
    `QT_QPA_PLATFORM=xcb` into libTAS to ensure it runs through X11.
    DELTARUNE can currently only run through X11.
- As stated above, chapter switching is not supported & will make the game exit.

## Q&A

### Why is this package considered insecure?
### Why am I building OpenSSL 1.0.2u?

The YoYo Games Linux Runner, which is responsible for running GameMaker games
like DELTARUNE, depends on OpenSSL 1.0, which has been end-of-life since 2019.
Insecure packages are not built for cache.nixos.org, and thus must instead
be built locally.

## Special Thanks

Special thanks to the [deltaport] maintainers for making this Nix/NixOS port
possible in the first place!


[^1]: This command downloads the files (depot)
of an app for a specific version (manifest.)
[`1671210`](https://steamdb.info/app/1671210/) is the App ID for DELTARUNE.
[`1671212`](https://steamdb.info/depot/1671212/) is the Depot ID for Windows
game files.
[`3006447521106301427`](https://steamdb.info/depot/1671212/history/?changeid=M:3006447521106301427)
is the Manifest ID
[associated with version 1.01C](https://steamdb.info/patchnotes/18791270/)



[DELTARUNE]: https://deltarune.com/
[deltaport]: https://github.com/pungus7/deltaport
[yoyo-games-runner-nix]: https://github.com/MichailiK/yoyo-games-runner-nix
[libTAS]: https://github.com/clementgallet/libTAS