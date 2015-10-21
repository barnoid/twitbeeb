TwitBeeb
========

This is the code for TwitBeeb, which is a BBC Micro B you can use to tweet from via a Raspberry Pi.

Twitbeeb requires the Acornsoft Termulator ROM (for BBC VDU Mode), a GPIO or USB to Serial Adapter for the Pi, and an appropriate BBC > Serial Cable. You can create your own cable from designs at http://www.cowsarenotpurple.co.uk/bbccomputer/serialcable.html and http://www.sprow.co.uk/bbc/extraserial.htm#Crossover.

To begin, Create a new Twitter Application for the account you wish to tweet from at http://dev.twitter.com and obtain the Consumer Key, Consumer Secret, plus your own personal OAuth Key and Secret. Clone this git into your home directory (e.g. /home/pi) and edit twitbeeb.rb with your favourite text editor, entering these values.

"twitbeeb_oauth.rb" is not required for normal operation, you can edit out the Line 24 require.

With the Termulator ROM Installed on the BBC Micro, press 1 to enter setup and set X-ON to OFF. Set the send and receive rate to an approproriate speed (higher than 4800 can cause data loss and corruption with some cables). Enter BBC VDU Mode by pressing 6.

From the Raspberry Pi Console, start Twitbeeb by running the command ./twitbeeb-run with the output location of your USB/GPIO serial device (e.g. ./twitbeeb-run /dev/ttyUSB0 or ./twitbeeb-run /dev/ttyAMA0 for GPIO).


More information at:
http://barnoid.org.uk/twitbeeb
