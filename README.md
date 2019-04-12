# transmission-reseeder
The purpose of this reseeder it to make the adding of previously downloaded material easier.
Once you have downloaded the content once, the magnetLINK is copied into a special shell script
which can be executed, on its own, to seed the content with transmission-** torrent client.
The reseeder application simple collects all these ***.magnetLINK files and adds them to be seeded once again.

# Limitations
Because of the nature of the transmission, only the linux version works with these tools. The windows
and mac versions might be supported someday. Whenever these platforms allow transmission-remote to be used.

Contact
basecase.fm@gmail.com
feel free to make requests for features or report bugs...im just doing this for fun..:>

Installation
Copy contents of the makeDirectoryForSeed.sh to a place that won't change and is accesible to your transmission install.
Go to Prefrences->Downloading->Incomplete there you will find the "Call script when torrent is completed"
select the file makeDirectoryForSeed.sh

For the reseeder 
Paste the contents of the reseeder to somewhere. Make the file executable. and run it via a terminal
ex: [user@hostname Downloads]$ ./reseeder
