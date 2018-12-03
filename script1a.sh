#!/bin/bash
touch up1 #A file that contains the URLs with blank lines deleted because wget can not work
sed '/^[[:space:]]*$/d' $1 > up1 #Deletion if the blank spaces and to up1.
if [ ! -d sites ]; then
    touch temp
    mkdir -p sites;
    while IFS='' read -r line || [[ -n "$line" ]]; do #Reading the URLs' file line by line.
    #Taking the first character of the URL to check if the line is a comment.
    tempChar=$(echo $line | head -c 1)
        if [ ! "$tempChar" == "#" ]; then
            #filename is the file that the HTML will be saved. Name of this file is the URL
            #without special characters.
            filename=$(echo $line | tr -dc '[:alnum:]\n\r')
            wget -qO sites/$filename $line
            if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                echo "$line FAILED" >> /dev/stderr
            else
                echo "$line INIT"
            fi
        fi
    done < up1
else
    while IFS='' read -r line || [[ -n "$line" ]]; do
        filename=$(echo $line | tr -dc '[:alnum:]\n\r')
        tempChar=$(echo $line | head -c 1)
        if [ ! "$tempChar" == "#" ]; then
            if [ ! -f sites/$filename ]; then #Checking if it is the first time reading this URL
                wget -qO sites/$filename $line
                if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                    echo "$line FAILED" >> /dev/stderr
                else
                    echo "$line INIT"
                fi
            else
                #temp is the file that it is going to be compared with the file that already 
                #exists for the URL.
                touch sites/temp
                wget -qO sites/temp $line
                if ! diff -q sites/temp sites/$filename > /dev/null; then
                    wget -qO sites/$filename $line #Copying the file if there is difference.
                    if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                        echo "$line FAILED" >> /dev/stderr
                        echo "FAILED" >> sites/$filename
                    else
                        echo "$line"
                    fi
                fi
            fi
        fi
    done < up1
fi
rm up1
rm sites/temp
    
