#!/usr/bin/ruby

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

SEARCH = "#DMMF12"
SUFFIX = " #{SEARCH}"
# Derby Old Silk Mill:
LAT = 52.925838
LONG = -1.475765

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

log = Logger.new('twitbeeb.log')
log.datetime_format = "%Y-%m-%d %H:%M:%S"
log.level = Logger::INFO

twitter = TwitterOauth.new(CONSUMER_KEY, CONSUMER_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

def escape(str)
  return URI.escape(str, /[^A-Za-z0-9\-\._~]/)
end


log.info("Starting")

while true do

	print RESET_WINS
	print CLS
	print " " * 29                            + CYAN + DOUBLE + "TwitBeeb\n\r"
	print YELLOW + '%.28s' % SEARCH.ljust(28) + CYAN + DOUBLE + "TwitBeeb\n\r"
	print SET_TEXT_WIN + 0.chr + 24.chr + 39.chr + 2.chr

	log.info("Searching for Tweets")	

	# Search Twitter into array
	lines = []
	tweets = JSON.parse open("http://search.twitter.com/search.json?q=#{escape(SEARCH)}&result_type=recent&rpp=20").read
	tweets['results'].each { |res|
		lines << GREEN + "#{res['from_user']}:" + WHITE + "#{res['text'].gsub(/[\r\n\x80-\xff]/,"")}"
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

	log.info("Waiting for input")

	# Get input char and deal with it appropriately
	readstr = ""
	while ch = STDIN.getc do
		#STDERR.puts "#{ch.inspect} #{ch.chr}"
		char_add = ""
		if ch == 127 then
			# delete
			if not readstr == "" then
				readstr = readstr[0..-2]
				print ch.chr
			end
		elsif ch == 96 then
			# pound sign
			char_add = "£"
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
	end

	log.info("Got input: #{readstr}")

	# Tweet if there's input
	if readstr != "" then
		print MOVE_TEXT_CURSOR + 0.chr + 10.chr

		print " " * 39 + "\r\n"
		print " " * 11 + DOUBLE + YELLOW + FLASH_ON + "PLEASE WAIT" + " " * 14 + "\r\n"
		print " " * 11 + DOUBLE + YELLOW + FLASH_ON + "PLEASE WAIT" + " " * 14 + "\r\n"
		print " " * 39 + "\r\n"

		readstr << SUFFIX
		log.info("Tweeting: #{readstr}")

		twitter_out = twitter.tweet_geo(readstr, LAT, LONG).body
		log.info("Twitter says: #{twitter_out}")

		sleep 5
	end

end
