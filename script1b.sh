#!/bin/bash
touch up #A file that contains the URLs with blank lines deleted because wget can not work
sed '/^[[:space:]]*$/d' $1 > up #Deletion if the blank spaces and to up.
if [ ! -d sites ]; then
    mkdir -p sites;
    while IFS='' read -r line || [[ -n "$line" ]]; do #Reading the URLs' file line by line.
        #Wait is used to terminate the program succesfully.
        (tempChar=$(echo $line | head -c 1)
        if [ ! "$tempChar" == "#" ]; then
            #filename is the file that the HTML will be saved. Name of this file is the URL
            #without special characters.
            #The difference with the URL by URL checking is on the file that program creates.
            filename=$(echo $line | tr -dc '[:alnum:]\n\r')
            wget -qO sites/$filename $line
            if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                echo "$line FAILED" >> /dev/stderr
            else
                echo "$line INIT"
            fi
        fi)&
        wait
    done < up
else
    #By using & at the end of while, all of the URLs are checked in the same time
    #wait is used to terminate the program succesfully.
    while IFS='' read -r line || [[ -n "$line" ]]; do
        (filename=$(echo $line | tr -dc '[:alnum:]\n\r')
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
                #Deleting the special characters and adding in the end of the name of the file
                #random letters to avoid conflict
                temp=$(echo "$filename asd" | tr -d '[:space:]\n\r')
                touch sites/$temp
                wget -qO sites/$temp $line
                if ! diff -q sites/$temp sites/$filename > /dev/null; then
                    wget -qO sites/$filename $line #Copying the file if there is difference.
                    if [ ! 0 -eq $? ]; then #Checking if wget was succesful
                        echo "$line FAILED" >> /dev/stderr
                        echo "FAILED" >> sites/$filename
                    else
                        echo "$line"
                    fi
                fi
                rm sites/$temp
            fi
        fi)&
        wait
    done < up
fi
    
