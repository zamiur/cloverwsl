# CloverOS GNU/Linux for Windows Subsystem for Linux (WIP)

### Included Scripts

`make_cloveros_distro.sh` - Makes the root filesystem tarball of CloverOS, ready for deployment as an out-of-the-box Gentoo image (stage4) with binhost

`clean.sh` - Clean up and remove output left by the scripts.

`build.bat` - makes the "distro launcher" appx.

### Commands

- `cloveros.exe`
  - Launches the user's default shell in the user's home directory.
- `cloveros.exe install [--root]`
  - Install the distribution and do not launch the shell when complete.
    - `--root`: Do not create a user account and leave the default user set to root.
- `cloveros.exe run <command line>`
  - Run the provided command line in the current working directory. If no command line is provided, the default shell is launched.
  - Everything after `run` is passed to WslLaunchInteractive.
- `cloveros.exe config [setting [value]]`
  - Configure settings for this distribution.
  - Settings:
    - `--default-user <username>`: Sets the default user to . This must be an existing user.
- `cloveros.exe help`
  - Print usage information.

### License

See [here](/LICENSE)

### Help

Would be greatly appreciated! I'm not working on this full time and also I am pretty new to shell scripting
