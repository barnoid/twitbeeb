#!/usr/bin/ruby
# encoding: utf-8

# TwitBeeb
# By Barney Livingston
# 2012-05-31

# This works with Termulator in BBC VDU mode.

$:.unshift File.dirname(__FILE__)

require "twitter_oauth"

require "json"
require "open-uri"
require "logger"
require "uri"

# These need to be set for your Twitter app and account.
CONSUMER_KEY=""
CONSUMER_SECRET=""
OAUTH_TOKEN=""
OAUTH_TOKEN_SECRET=""
require "twitbeeb_oauth_params"

SEARCH = "#BMMF15"
SUFFIX = " #{SEARCH}"
# Derby Old Silk Mill:
#LAT = 52.925838
#LONG = -1.475765
# Bristol M Shed
#LAT = 51.447796
#LONG = -2.597993
# At-Bristol
LAT = 51.450419
LONG = -2.600701

# BBC VDU codes
# http://central.kaserver5.org/Kasoft/Typeset/BBC/Ch34.html
# http://central.kaserver5.org/Kasoft/Typeset/BBC/Ch28.html
CLS = 12.chr
RESET_WINS = 26.chr
SET_TEXT_WIN = 28.chr
MOVE_TEXT_CURSOR = 31.chr
RED = 129.chr
GREEN = 130.chr
YELLOW = 131.chr
BLUE = 132.chr
MAGENTA = 133.chr
CYAN = 134.chr
WHITE = 135.chr
FLASH_ON = 136.chr
FLASH_OFF = 137.chr
DOUBLE = 141.chr
BACKGROUND = 157.chr

$log = Logger.new('twitbeeb.log')
$log.datetime_format = "%Y-%m-%d %H:%M:%S"
$log.level = Logger::DEBUG

twitter = TwitterOauth.new(CONSUMER_KEY, CONSUMER_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)


def twitlist(twitter)
	print RESET_WINS
	print CLS
	print YELLOW + '%.28s' % SEARCH.ljust(28) + CYAN + DOUBLE + "TwitBeeb\n\r"
	print " " * 29                            + CYAN + DOUBLE + "TwitBeeb\n\r"
	print SET_TEXT_WIN + 0.chr + 24.chr + 39.chr + 2.chr

	$log.info("Searching for Tweets")

	# Search Twitter into array
	lines = []
	tweets = JSON.parse(twitter.search(SEARCH).body)
	$log.debug(tweets)
	tweets['statuses'].each { |res|
		lines << GREEN + "#{res['user']['screen_name']}:" + WHITE + "#{res['text'].gsub(/[^0-9A-Za-z -_,\.\?\#@;:\+\(\)\*&\^%\$£"!'~<>\/\\]/, "")}"
	}

	# Split search results at 40 chars for Mode 7
	lines_split = []
	lines.each { |line|
		line.scan(/.{39}|.+/).each { |part|
			lines_split << part
		}
	}

	# Print 22 lines
	c = 0
	while c < lines_split.size and c < 22 do
		print lines_split[c] + "\r\n"
		c += 1
	end

	# Prompt
	print ">"
end

def infopage1
	print RESET_WINS
	print CLS
	print YELLOW + '%.28s' % SEARCH.ljust(28) + CYAN + DOUBLE + "TwitBeeb\n\r"
	print " " * 29                            + CYAN + DOUBLE + "TwitBeeb\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print " This is a BBC B connected to a\n\r"
	print " Raspberry Pi. The displayed tweets\n\r"
	print " are recent matches of the search\n\r"
	print " in the top-left of the screen. Type\n\r"
	print " at the prompt and press the Return\n\r"
	print " key to send a tweet from the @twitbeeb\n\r"
	print " account. The search string is appended\n\r"
	print " for you.\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print " " * 6 + DOUBLE + YELLOW + FLASH_ON + "PRESS ANY KEY TO TWEET\r\n"
	print " " * 6 + DOUBLE + YELLOW + FLASH_ON + "PRESS ANY KEY TO TWEET\r\n"
end

def infopage2
	print RESET_WINS
	print CLS
	print YELLOW + '%.28s' % SEARCH.ljust(28) + CYAN + DOUBLE + "TwitBeeb\n\r"
	print " " * 29                            + CYAN + DOUBLE + "TwitBeeb\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print WHITE + BACKGROUND + "\n\r"
	print WHITE + BACKGROUND + " " * 10 +                "                \n\r"
	print WHITE + BACKGROUND + " " * 10 + RED + DOUBLE + "Bristol" + CYAN + "Mini   \n\r"
	print WHITE + BACKGROUND + " " * 10 + RED + DOUBLE + "Bristol" + CYAN + "Mini   \n\r"
	print WHITE + BACKGROUND + " " * 10 + RED + DOUBLE + "Maker  Faire   \n\r"
	print WHITE + BACKGROUND + " " * 10 + RED + DOUBLE + "Maker  Faire   \n\r"
	print WHITE + BACKGROUND + " " * 10 +              "                \n\r"
	print WHITE + BACKGROUND + "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print " " * 6 + DOUBLE + YELLOW + FLASH_ON + "PRESS ANY KEY TO TWEET\r\n"
	print " " * 6 + DOUBLE + YELLOW + FLASH_ON + "PRESS ANY KEY TO TWEET\r\n"
end


$log.info("Starting")

readstr = ""
dispcounter = 0

# Delays for rotating between screens
DISP_TWIT1 = 0
DISP_TWIT2 = 200
DISP_INFO1 = 1200
DISP_INFO2 = 1800
DISP_RESET = 2400

# Display thread
Thread.new do
	while true do
		#STDERR.puts "#{dispcounter} #{readstr.inspect}"
		if readstr == "" then
			dispcounter = 0 if dispcounter >= DISP_RESET
			twitlist(twitter) if dispcounter == DISP_TWIT1
			twitlist(twitter) if dispcounter == DISP_TWIT2
			infopage1 if dispcounter == DISP_INFO1
			infopage2 if dispcounter == DISP_INFO2
			dispcounter += 1
		end
		sleep 0.1
	end
end


# Input loop
while true do
	#twitlist(twitter)
	$log.info("Waiting for input")

	# Get input char and deal with it appropriately
	readstr = ""
	dispcounter = 0
	while true do
		ch = 0
		begin
			ch = STDIN.read_nonblock(1).ord
		rescue Errno::EAGAIN
			# nothing to read
		rescue
			# ah well
		end
		#STDERR.puts "#{ch} #{ch.inspect} #{ch.chr}"
		if dispcounter < DISP_INFO1 then
			char_add = ""
			if ch == 0 then
				# nothing
			elsif ch == 127 then
				# delete
				if not readstr == "" then
					readstr = readstr[0..-2]
					print ch.chr
				end
			elsif ch == 96 then
				# pound sign
				char_add = '£'
			elsif ch == 27 then
				# escape
				readstr = ""
				break
			elsif ch == 13 then
				# return
				break
			else
				char_add = ch.chr
			end
			if readstr.size < 140 - SUFFIX.size then
				readstr << char_add
				print char_add
			end
		else
			dispcounter = 0 if ch > 0
		end
		sleep 0.1
	end

	$log.info("Got input: #{readstr}")

	# Tweet if there's input
	if readstr != "" then
		print MOVE_TEXT_CURSOR + 0.chr + 10.chr

		print " " * 39 + "\r\n"
		print " " * 11 + DOUBLE + YELLOW + FLASH_ON + "PLEASE WAIT" + " " * 14 + "\r\n"
		print " " * 11 + DOUBLE + YELLOW + FLASH_ON + "PLEASE WAIT" + " " * 14 + "\r\n"
		print " " * 39 + "\r\n"

		readstr << SUFFIX
		$log.info("Tweeting: #{readstr}")

		twitter_out = twitter.tweet_geo(readstr, LAT, LONG).body
		$log.info("Twitter says: #{twitter_out}")

		sleep 5
	end

end
