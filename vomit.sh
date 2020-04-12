#!/bin/bash
# Just something hacky to make my life a little easier
#Bret-RetroPie-Pi4-Weekly = $bucketname
sleep 1
echo "This script will prompt for your Backblaze B2 applicationKeyId and applicationKey if you're not already authed and then ask for bucket name and local/remote filenames"
sleep 3
#echo "I'll make it do a little more at some point.."

# Get the PID to bodge a kill later if something goes wrong
PID=$BASHPID

# Check if this instance is already authenticated with a B2 Backblaze account. If not, prompt for login.
echo "Checking if we're already authenticated with B2..."
if [[ $(grep capabilities ~/.b2_account_info) = *matches* ]]; then
        echo "Logged in"
	read -p "We also need the exact bucket name you wish to upload to: " bucketname
else
        echo "Not logged in! Let's fix that."
        sleep 2 
        b2 authorize-account
	#read -p "We also need the exact bucket name you wish to upload to: " bucketname
fi

# Now we're logged in, we need to download the source file.
read -p "Link to file you wish to download: " downloadurl
read -p "What filename do you want to use on B2? " b2filename
echo "Attempting to download $downloadurl and upload it to Backblaze B2 as $b2filename"
sleep 2
wget $downloadurl
if [[ $(b2 list-file-names $bucketname | grep $b2filename) = *"$b2filename"* ]]; then
	echo "This file exists already, wat doink"
else
	echo "This looks new, let's upload!"
	sleep 3
fi

# We've downloaded the files, now we need to push it to Backblaze B2
read -p "What's the local file called? " localfilename
if [[ $(stat $localfilename) = *"Birth"* ]]; then
        echo "This file doesn't exist. Double check your spelling"
else
	echo "Looks good. Uploading!"
	sleep 2
fi
b2 upload-file --minPartSize 2000 --threads 25 $bucketname $localfilename $b2filename
