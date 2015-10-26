#!/bin/sh

##Save Old directory and Create Placeholder for New directory
OLD_DIR="$TR_TORRENT_DIR"
NEW_DIR="$TR_TORRENT_DIR"/"$TR_TORRENT_NAME"-DIR

##Check if Current Directory has been Modified by Script
if [[ $OLD_DIR =~ \-DIR ]]
then
  echo " Directory already processed"
  NEW_DIR=$OLD_DIR

else
  echo "Proceeed, not processed yet"

## Create New Directory
  mkdir "$NEW_DIR"

## Move File/Folder from Old Directory to New Directory
  mv "$TR_TORRENT_DIR"/"$TR_TORRENT_NAME" "$NEW_DIR"

fi
## Copy Magnet link into a file
magnetLINK=$(transmission-remote -t $TR_TORRENT_ID -i | grep "Magnet:" | sed -r 's/^.{10}//')

cat > "$NEW_DIR"/"$TR_TORRENT_NAME".magnetLINK <<EOL
#!/bin/sh
name="$TR_TORRENT_NAME"

magnetLINK="$magnetLINK"
currentDIR="$(pwd)"

test "\$(transmission-remote -l | grep "\$name")" == "" && ( transmission-remote -a "\$magnetLINK" -w "\$currentDIR" )
EOL

## Change to new location in Transmission"
transmission-remote -t $TR_TORRENT_ID --move "$NEW_DIR"

echo "Torrent placed its own folder for easy seeding"
