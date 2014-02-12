imgsort
=======

[![Build Status](https://travis-ci.org/spencerwi/imgsort.png?branch=master)](https://travis-ci.org/spencerwi/imgsort)

Sorts images by aspect ratio, optionally using a per-folder rules file (named ".imgsortrc") for destination folder names


Usage
-----

    imgsort [options] <directory>...

    Options:
        -h, --help      Show this screen
        -v, --verbose   Verbose output
        -d, --daemon    Daemonize
        

If `-d`/`--daemonize` is specified, imgsort will run as a continuous process, watching the specified directory for new files and sorting them as appropriate. 


Rules File
----------

Each directory that imgsort operates in can optionally specify sorting rules in a JSON rules file, named .imgsortrc.

This file lists mappings of aspect ratios (in WxH format) or the word "default" to target folders (relative to the sorted directory).

For example, the default ruleset could be manually designated in the following rules file:

```json
{
    "16x9"   : "16x9",
    "16x10"  : "16x10",
    "4x3"    : "4x3",
    "default": "misc"
}
```

In this case, images with a 16x9 aspect ratio would be placed in a folder called "16x9", and so on.
Any images not matching one of the aspect ratios listed would be placed in a folder named "misc".

If one of the specified folders does not exist, imgsort will first create it, then move the file.


Ignored files
-------------

imgsort only operates on image files; non-image files are left in place. Additional filename patterns to ignore may be specified as regular expressions in a directory's rules file, in an array under the "ignore" key.

For example, the following rules file will cause all files ending in ".gif" or ".bmp", or beginning in "ignoreme_" to be ignored:

```json
{
    "ignore": [ 
        ".gif$",
        ".bmp$",
        "^ignoreme_"
    ]
}
```
