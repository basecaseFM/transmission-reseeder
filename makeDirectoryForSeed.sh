#!/bin/sh

#---------------------------------------------------------------------------------------------------------------------------#
#		This script is designed to make seeding already downloaded content easier. It does this by saving           #
#	torrent to the newly created download directory and creating a magnetLINK shell script that contains everything	    #
#	needed to easily reseed content, including the magnetlink and a mechanism to handle Transmission authenication      #
#	and remote sessions.												    #
#				Feel free to customise this script as needed. Any suggestions or improvements can be        #
#				directed to the Github project   TRANSMISSION-RESEEDER on GITHUB.COM			    #
#															    #
#	Limitation: Does not support Username and password at the moment. Support coming soon!!				    #
#															    #
#---------------------------------------------------------------------------------------------------------------------------#

## Port-Host Selection [enter non-default port or host values]
remotePORT=9091 
remoteHOST=localhost

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

##  Copy Magnet link into a a variable for the .magnetLINK file
## Removed for possible private tracker conflicts
#magnetLINK=$(transmission-remote $remoteHOST:$remotePORT -t $TR_TORRENT_HASH -i | grep ^"  Magnet:" | sed -r 's/^.{10}//')

##  Copy torrent from transmission config directory to download directory
cp /home/$USER/.config/transmission/torrents/"$TR_TORRENT_HASH"*.torrent "$NEW_DIR"
 
##  Create "torrent name".magnetLINK bash script 
cat > "$NEW_DIR"/"$TR_TORRENT_NAME".magnetLINK <<EOL
#!/bin/sh
torrent_name="$TR_TORRENT_NAME"
#magnetLINK="$magnetLINK"
torrent_hash=$TR_TORRENT_HASH

if [[ -z \$1 && -z \$3 && -z \$4 ]] ; then
	alias transmission-remote="transmission-remote"
elif [[ -n \$1 && -z \$3 && -z \$4 ]] ; then
	alias transmission-remote="transmission-remote --auth \$1:\$2"
elif [[ -z \$1 && -n \$3 && -z \$4 ]] ; then
	alias transmission-remote="transmission-remote \$3"
elif [[ -z \$1 && -z \$3 && -n \$4 ]] ; then
	alias transmission-remote="transmission-remote \$4"
elif [[ -z \$1 && -n \$3 && -n \$4 ]] ; then
	alias transmission-remote="transmission-remote \$3:\$4"	
elif [[ -n \$1 && -n \$3 && -z \$4 ]] ; then
	alias transmission-remote="transmission-remote \$3 --auth \$1:\$2"
elif [[ -n \$1 && -z \$3 && -n \$4 ]] ; then
	alias transmission-remote="transmission-remote \$4 --auth \$1:\$2"
elif [[ -n \$1 && -n \$3 && -n \$4 ]] ; then
	alias transmission-remote="transmission-remote \$3:\$4 --auth \$1:\$2"
fi	
 
currentDIR="\$( cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd )"
foundSTRING="\$(transmission-remote -t \$torrent_hash -ip)"
declare -a torrentFiles
for file in "\$currentDIR"\/*.torrent
do
    torrentFiles=("\${torrentFiles[@]}" "\$file")
done

if [ -z "\$foundSTRING" ]
then
    for torrent in "\${torrentFiles[@]}"
    do
        transmission-remote -a "\$torrent" -w "\$currentDIR" || transmission-remote -a "\$magnetLINK" -w "\$currentDIR"
        transmission-remote -t \$torrent_hash -v
    done
   echo "Torrent is NOT already loaded in Transmission"

else
   transmission-remote -t \$torrent_hash --find "\$currentDIR"
   transmission-remote -t \$torrent_hash -s
   echo "Torrent already in list, moving to current location."
fi
EOL

## Change to new location in Transmission"
transmission-remote $remoteHOST:$remotePORT -t $TR_TORRENT_HASH --move "$NEW_DIR"

echo "Torrent placed its own folder for easy seeding"
