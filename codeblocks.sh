#!/bin/bash

shopt -s extglob

CWD="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# A warning to the user
echo "WARNING: The current Bash Script does not support space-separated source/header filenames."

# Set all configs
echo -n "Enter a workspace folder: "
read workspace_folder
echo $workspace_folder

mkdir "$CWD/$workspace_folder/CodeBlocks/"

cd "$workspace_folder"

# Copy all workspace files and folders into the directory
cp !(CodeBlocks) "$CWD/$workspace_folder/CodeBlocks/".

# Copy data_2 into the project as some_workspace_folder_name.cbp
cp "$CWD/data_2.dat" "CodeBlocks"/$(basename "$workspace_folder").cbp

# Change the project folder name within .cbp to the workspace folder name
sed -i "s/ProjectNameMatchHere/"$(basename "$workspace_folder")"/g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp

# Check if there's source files other than main.(cpp/c)
if compgen -G "!(main).cpp" > /dev/null; then
    # Separate source and header files into src/ and include/
    mkdir "$CWD/$workspace_folder/CodeBlocks/src"
    mkdir "$CWD/$workspace_folder/CodeBlocks/include"

    # Also add header includes into .cbp file
    sed -i "s/DebugCompilerArgsPatternMatchHere/<Add directory=\"include\" \/>/g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp
    sed -i "s/ReleaseCompilerArgsPatternMatchHere/<Add directory=\"include\" \/>/g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp

    echo "List of .cpp files other than main file:"
    source=( "$(echo !(main).cpp | sed 's/ /\n/g' )" )

    for (( i = 0; i < ${#source[@]}; i++ )); do
        echo "${source[$i]}"

        # For each file, we move it to src/
        mv "CodeBlocks/${source[$i]}" "CodeBlocks/src/${source[$i]}"

        # Also add a link to the file
        sed -i "s/AdditionalFilenamesPatternMatchHere/<Unit filename=\"src\/${source[$i]}\" \/>\nAdditionalFilenamesPatternMatchHere/g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp
    done

    echo "List of .h and .hpp files other than main file:"
    headers=( "$(echo *.h | sed 's/ /\n/g' )" )
    headers+=( "$(echo *.hpp | sed 's/ /\n/g' )" )

    for (( i = 0; i < ${#headers[@]}; i++ )); do
        echo "${headers[$i]}"

        # For each file, we move it to include/
        mv "CodeBlocks/${headers[$i]}" "CodeBlocks/include/${headers[$i]}"

        # Also add a link to the file
        sed -i "s/AdditionalFilenamesPatternMatchHere/<Unit filename=\"include\/${headers[$i]}\" \/>\nAdditionalFilenamesPatternMatchHere/g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp
    done

    # Remove pattern point for additional file includes from .cbp
        sed -i "s/AdditionalFilenamesPatternMatchHere//g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp
else
    echo "Seems like there's only a main file here."

    # Remove all pattern points from .cbp file
    sed -i "s/DebugCompilerArgsPatternMatchHere//g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp
    sed -i "s/ReleaseCompilerArgsPatternMatchHere//g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp
    sed -i "s/AdditionalFilenamesPatternMatchHere//g" "CodeBlocks"/"$(basename "$workspace_folder")".cbp
fi

shopt -u extglob