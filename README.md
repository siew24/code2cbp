# code2cbp
A simple Bash script to automate the conversion of C++ files into a CodeBlocks project.

This small project arised from the sheer amount of time needed for me to create each CodeBlocks project just for each singular question from an assignment. So I thought to myself: *Why not just code in VS Code and then automate the conversion process?*

Hopefully someone will find this useful as I did!

## Get Started
Just download both of the files: `codeblocks.sh` and `data_2.dat`.

Here's a simple explanation on where to put the files:
```
some_big_dir
|
- workspace_dir
  |
  - main.cpp
  - sources.cpp
  - some_headers.h
|
- sh_and_dat_files_go_here
```

To use the script, just type `./codeblocks.sh` within `some_big_dir` on Bash to start the process.

## Some notes

* Currently only .cpp, .h and .hpp files are supported
* The current script does not support space-separated source/header filenames
* All source files and header files must be at the root of your workspace folder as the script does not check recursively for those files
