#!/bin/bash
#A directory to store the files of the tar.gz file.
if [ ! -d files ]; then
    mkdir files
fi
tar -xzf $1 -C files
touch files/repos #File that contains the URLs of the repositories
find files -type f -name "*.txt" | while read txt; do
    #for every txt file, finds the first 'https'-started URL.
    while IFS='' read -r line || [[ -n "$line" ]]; do
        tmpChar=$(echo $line | head -c 5)
        if [ "$tmpChar" == "https" ]; then
            echo $line >> files/repos #Copying the Repository URL in repos and moves to next file.
            break
        fi
    done < $txt
done
if [ ! -d assignments ]; then
    mkdir assignments
fi
while IFS='' read -r line || [[ -n "$line" ]]; do
    cd assignments #Changing the directory to save the repository to assignments
    git clone $line &> /dev/null
    if [ ! 0 -eq $? ]; then #Checking if cloning was succesful
        echo "$line: Cloning FAILED"
    else
        echo "$line: Cloning OK"
    fi
    cd .. #Returns to previous directory to take the next URL, before it changes again.
done < files/repos
echo ""
cd assignments
#Checking for the structure and counts the number of directories, txt files, and other files
for d in *; do
    echo "$d:"
    structure=false #A flag to check if the structure is correct
    cd $d
    numTxt=$(find * -type f -name "*.txt" | wc -l) #Counts txt files of the repository
    numDir=$(find * -type d | wc -l) #Counts directories of the repository
    numFil=$(find * -type f -not -name "*.txt" | wc -l) #Counts other files of the repository
    if [ $numTxt -eq 3 ] && [ $numDir -eq 1 ] && [ $numFil -eq 0 ]; then
        if [ -f dataA.txt ]; then
            if [ -d more ]; then
                if [ -f more/dataB.txt ]; then
                    if [ -f more/dataC.txt ]; then
                        structure=true
                    fi
                fi
            fi
        fi
    fi
    echo "Number of directories: $numDir"
    echo "Number of txt files: $numTxt"
    echo "Number of other files: $numFil"
    if [ $structure = true ]; then
        echo "Directory structure is OK"
    else
        echo "Directory structure is not OK"
    fi
    cd ..
    echo ""
done

