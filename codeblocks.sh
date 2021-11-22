#!/bin/bash

shopt -s extglob

CWD="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# A warning to the user
echo "WARNING: The current Bash Script does not support space-separated source/header filenames."

# Set all configs
echo -n "Enter a workspace folder: "
read workspace_folder
echo $workspace_folder

if mkdir "$CWD/$workspace_folder/CodeBlocks/"; then
    echo "Generating CodeBlocks folder..."
else
    echo "Looks like CodeBlocks folder exists here."
    echo "Regenerating CodeBlocks folder..."
    rm -rf "$CWD/$workspace_folder/CodeBlocks/" && echo "Cleaned CodeBlocks folder."
    mkdir "$CWD/$workspace_folder/CodeBlocks/"
fi

echo "Success!"

cd "$workspace_folder"

workspace_name="$(basename "$workspace_folder")"

# Copy all workspace files and folders into the directory
cp !(CodeBlocks) "$CWD/$workspace_folder/CodeBlocks/".

# Copy data_2 into the project as some_workspace_folder_name.cbp
cp "$CWD/data_2.dat" "CodeBlocks"/"$workspace_name".cbp

# Change the project folder name within .cbp to the workspace folder name
sed -i "s/ProjectNameMatchHere/$workspace_name/g" "CodeBlocks"/"$workspace_name".cbp

# Check if there's source files other than main.(cpp/c)
if compgen -G "!(main).cpp" > /dev/null; then
    # Separate source and header files into src folder
    mkdir "$CWD/$workspace_folder/CodeBlocks/src"

    echo "List of .cpp files other than main file:"
    source=($(echo !(main).cpp))

    for (( i = 0; i < ${#source[@]}; i++ )); do
        echo "${source[$i]}"

        # For each file, we move it to src/
        mv "CodeBlocks/${source[$i]}" "CodeBlocks/src/${source[$i]}"

        # Also add a link to the file
        sed -i "s/AdditionalFilenamesPatternMatchHere/<Unit filename=\"src\/${source[$i]}\" \/>\nAdditionalFilenamesPatternMatchHere/g" "CodeBlocks"/"$workspace_name".cbp
    done
fi
if compgen -G "*.hpp" > /dev/null; then
    # Header files are put into include folder
    mkdir "$CWD/$workspace_folder/CodeBlocks/include"

    # Also add header includes into .cbp file
    sed -i "s/DebugCompilerArgsPatternMatchHere/<Add directory=\"include\" \/>/g" "CodeBlocks"/"$workspace_name".cbp
    sed -i "s/ReleaseCompilerArgsPatternMatchHere/<Add directory=\"include\" \/>/g" "CodeBlocks"/"$workspace_name".cbp

    echo "List of .hpp files"

    headers=($(echo *.hpp))
    
    for (( i = 0; i < ${#headers[@]}; i++ )); do
        echo "${headers[$i]}"

        # For each file, we move it to include/
        mv "CodeBlocks/${headers[$i]}" "CodeBlocks/include/${headers[$i]}"

        # Also add a link to the file
        sed -i "s/AdditionalFilenamesPatternMatchHere/<Unit filename=\"include\/${headers[$i]}\" \/>\nAdditionalFilenamesPatternMatchHere/g" "CodeBlocks"/"$workspace_name".cbp
    done

else
    echo "Seems like there's only source file(s) here."

    # Remove all pattern points from .cbp file
    sed -i "s/DebugCompilerArgsPatternMatchHere//g" "CodeBlocks"/"$workspace_name".cbp
    sed -i "s/ReleaseCompilerArgsPatternMatchHere//g" "CodeBlocks"/"$workspace_name".cbp
fi

sed -i "s/AdditionalFilenamesPatternMatchHere//g" "CodeBlocks"/"$workspace_name".cbp

shopt -u extglob