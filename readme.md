# CloverOS GNU/Linux for Windows Subsystem for Linux (WIP)

This is a fork of [Microsoft's WSL Distro Launcher](https://github.com/microsoft/WSL-DistroLauncher) for use with CloverOS GNU/Linux.

### Requirements

- **Internet**

- **An already working WSL instance** 

  *This is for running the two .sh scripts as they depend on Linux (and chroot especially) . If you want you can use other Linux environemts like MinGW and Cygwin to run the scripts.*

- **Windows 10** (for using WSL and running/building the launcher)

- **Visual Studio** (for building the launcher)

### Included Scripts

`make_cloveros_distro.sh` - Makes the root filesystem tarball of CloverOS, ready for deployment as an out-of-the-box Gentoo image (stage4) with binhost

`clean.sh` - Clean up and remove output left by the scripts.

`build.bat` - makes the "distro launcher" appx.

### Instructions

Make a copy of this repository

```
git clone https://github.com/zamiur/cloverwsl.git
```

Run the `make_cloveros_distro.sh` script to generate the distro.tar.gz. Then after that, move the archive to the root of the project file

Generate a test certificate:

1. In Visual Studio, open `DistroLauncher-Appx/MyDistro.appxmanifest`
2. Select the Packaging tab
3. Select "Choose Certificate"
4. Click the Configure Certificate drop down and select Create test certificate.

### Commands

`cloveros.exe`

Launches the user's default shell in the user's home directory.

`cloveros.exe install [--root]`

- Install the distribution and do not launch the shell when complete.
  - `--root`: Do not create a user account and leave the default user set to root.

`cloveros.exe run <command line>`

- Run the provided command line in the current working directory. If no command line is provided, the default shell is launched.
- Everything after `run` is passed to WslLaunchInteractive.

`cloveros.exe config [setting [value]]`

- Configure settings for this distribution.
- Settings:
  - `--default-user <username>`: Sets the default user to <username>. This must be an existing user.

`cloveros.exe help`

- Print usage information.

### Known Issues

**make_cloveros_distro.sh**

- `tar: ./dev/<device_name>: Cannot mknod: Operation not permitted`
- 

### License

See [here](/LICENSE)

### Help

Would be greatly appreciated! I'm not working on this full time and also I am pretty new to shell scripting. Also there's a lot of things I have to fix with the `make_cloveros_distro.sh` script.

### External Resources

[Creating a Custom Linux Distro for WSL](https://docs.microsoft.com/en-us/windows/wsl/build-custom-distro)

[CloverOS GNU/Linux](https://cloveros.ga)