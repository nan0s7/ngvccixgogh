# ngvccixgogh
A Bash script to allow automatic profile creation of colour schemes computed by GVCCI via Gogh.

Please check out each respective project used here; [Gogh](https://github.com/Mayccoll/Gogh) and [GVCCI](https://github.com/FabriceCastel/gvcci)!

## Dependencies
- Bash (I'm sure >v3 will work well)
- git
- Everything you need for GVCCI to work (python3 and modules)

You will also need to be using a supported Terminal emulator unless you plan on helping someone add support, of course!

## Setup
- Make sure nlinker.sh and ngoghbase.sh are executable: `chmod +x <file_name>`
- `cd` to a directory to place everything
- Run `git clone https://github.com/FabriceCastel/gvcci`
- Run `git clone https://github.com/nan0s7/ngvccixgogh`
- `cd` into **ngvccixgogh**
- Run `nlinker.sh` with desired arguments (see below)

## Usage
**nlinker.sh** accepts two arguments, the path to the image you want to get the colours from, and the name of the profile to be created from those colours.

`./nlinker.sh </path/to/image> <name>`

**nlinker_urxvt** uses a different format:
`./nlinker_urxvt.sh </path/to/image> </path/to/.Xresources>`

If no _.Xresources_ file is specified, it will default to /home/$user/.Xresources.

Please know this is an experiment and functionality may change at any time.
