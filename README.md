# OMXTool
Graphical Utility Tool for [OpenMX](http://www.openmx-square.org).

Copyright (C), 2015-2017, Naoya Yamaguchi.

This software includes the work that is distributed in version 3 of the GPL (GPLv3).

## Log:
- 2015/07/10 Ver. alpha-1 Written by Naoya Yamaguchi.
- 2015/07/13 Ver. alpha-2 Written by Naoya Yamaguchi.
- 2015/07/15 Ver. alpha-3 Written by Naoya Yamaguchi.
- 2015/07/16 Ver. alpha-4 Written by Naoya Yamaguchi.
- 2015/08/24 Ver. alpha-5 Written by Naoya Yamaguchi.
- 2015/11/12 Ver. beta-1 Written by Naoya Yamaguchi.
- 2016/03/17 Ver. alpha-6 Written by Naoya Yamaguchi.
- 2016/06/11 Ver. 1.0 Released by Naoya Yamaguchi.
- 2016/08/19 Ver. 1.1 Released by Naoya Yamaguchi.
- 2016/09/23 Ver. 1.2 Released by Naoya Yamaguchi.
- 2016/10/01 Ver. 1.2.1 Modified by Naoya Yamaguchi.
- 2016/10/04 Ver. 1.2.2 Modified by Naoya Yamaguchi.
- 2016/10/18 Ver. 1.2.3 Modified by Naoya Yamaguchi.
- 2016/12/09 Ver. 1.2.4 Modified by Naoya Yamaguchi.
- 2016/12/17 Ver. 1.3 Released by Naoya Yamaguchi.
- 2016/12/18 Ver. 1.3.1 Modified by Naoya Yamaguchi.
- 2017/01/02 Ver. 1.3.2 Modified by Naoya Yamaguchi.
- 2017/01/15 Ver. 1.4 Released by Naoya Yamaguchi.
  (renaming 'openmx.tcl' 'OMXTool.tcl')
- 2017/02/11 Ver. 1.4.1 Modified by Naoya Yamaguchi.
- 2017/02/13 Ver. 1.4.2 Modified by Naoya Yamaguchi.
  (renaming 'OMXTool.tcl' 'omxtool')
- 2017/03/04 Ver. 1.4.3 Modified by Naoya Yamaguchi.
- 2017/03/09 Ver. 1.5 Released by Naoya Yamaguchi.
- 2017/03/09 Ver. 1.5.1 Modified by Naoya Yamaguchi.
- 2017/03/13 Ver. 1.5.2 Modified by Naoya Yamaguchi.
- 2017/03/13 Ver. 1.5.3 Modified by Naoya Yamaguchi.
- 2017/03/13 Ver. 1.5.4 Modified by Naoya Yamaguchi.
- 2017/03/30 Ver. 1.5.5 Modified by Naoya Yamaguchi.
- 2017/06/18 Ver. 1.5.6 Modified by Naoya Yamaguchi.
- 2017/08/11 Ver. 1.5.7 Modified by Naoya Yamaguchi.
- 2017/08/20 Ver. 1.5.8 Modified by Naoya Yamaguchi.
- 2017/09/26 Ver. 1.5.9 Modified by Naoya Yamaguchi.
- 2017/11/18 Ver. beta-2 Written by Naoya Yamaguchi.

## Description:
   This script provides graphical utilities for OpenMX.

   **OMXTool** helps you do the following processes through a GUI.

### Using OMXTool, you can
- draw figures of band dispersions.
- convert the byte order (endianness) of 'SCFOUT file'. (`tclsh8.5` or later is required.)

## Requirements
- `wish` (Windowing Shell) and `gnuplot` are required.

## Installation
1. Download `OMXTool-*.tar.gz` or `OMXTool-*.zip` from [here](https://github.com/Ncmexp2717/OMXTool/releases) and unzip it. (Usually, \*=*version*.)
1. Put `omxtool` on your computer.

### For Upgrade
1. Overwrite `omxtool`.
1. Launch it and reset the settings via menu: ***Option -> Reset***.

## Usage:
   `./omxtool`

   or:

   `./omxtool &`

## How to
### start up:
1. Try `./omxtool` and launch a GUI of **OMXTool** as shown in the figure below.

- We recommend to launch 'OMXTool' as a background process (*i.e.* `./omxtool &`).

![GUI of 'OMXTool'](https://github.com/Ncmexp2717/OMXTool/raw/images/figure1.png)
### draw figures of band dispersions:
1. Click the `Band` button.
1. Select a \*.Band file and you can see a preview of the band dispersion as shown in the figures below.

![File open dialog](https://github.com/Ncmexp2717/OMXTool/raw/images/figure2.png)
![Preview window of a band dispersion](https://github.com/Ncmexp2717/OMXTool/raw/images/figure3.png)
- How to save the figures:
  1. Click the `Export` button and open a dialog box to save the figure.
  2. Save the figure through the dialog box.

![Save dialog](https://github.com/Ncmexp2717/OMXTool/raw/images/figure4.png)

### set options for gnuplot:
1. Click the `Option` button and open the `Option` window for the setting.
1. Set gnuplot options.

![Option](https://github.com/Ncmexp2717/OMXTool/raw/images/figure5.png)

- The settings are saved on clicking the `Close` button in the `Option` window.
- Clicking the `Reset` button sets them the default settings.
