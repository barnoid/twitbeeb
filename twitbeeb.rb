#!/usr/bin/ruby
# encoding: utf-8

# TwitBeeb
# By Barney Livingston
# 2012-05-31

# This works with Termulator in BBC VDU mode.

Thread.abort_on_exception = true

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
require "emfbeeb_oauth_params"
MY_ACCT = "emfbeeb"

SEARCH = "emfcamp"
SUFFIX = " ##{SEARCH}"
# Derby Old Silk Mill:
#LAT = 52.925838
#LONG = -1.475765
# Bristol M Shed
#LAT = 51.447796
#LONG = -2.597993
# At-Bristol
#LAT = 51.450419
#LONG = -2.600701
# Bristol Hackspace
#LAT = 51.442991
#LONG = -2.5938372
# EMF 2016 Bar
LAT = 51.21162
LONG = -0.60758

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
G_RED = 145.chr
G_GREEN = 146.chr
G_YELLOW = 147.chr
G_BLUE = 148.chr
G_MAGENTA = 149.chr
G_CYAN = 150.chr
G_WHITE = 151.chr
BACKGROUND = 157.chr

# clean twitter text
def clean_text(text)
	# fix encoding
	out_txt = text.encode("ASCII-8BIT", :invalid => :replace, :undef => :replace)
	# only allow safe chars
	out_txt.gsub!(/[^0-9A-Za-z -_,\.\?\#@;:\+\(\)\*&\^%\$£"!'~<>\/\\]/, "")
	out_txt.gsub!(/&amp;/, '&') # fix some HTML entities
	out_txt.gsub!(/&quot;/, '"')
	out_txt.gsub!(/https?:\/\/[\S]+/, '') # remove this to allow URLs
	out_txt.gsub!(/\s\s+/, ' ') # collapse multiple spaces
	return out_txt
end

def print_list(list, cols, rows)
	# Wrap lines at cols
	lines_wrap = []
	list.each do |text|
		text.scan(/.{1,#{cols}}(?:\s+|\Z|-)/).each do |part|
			lines_wrap << part.gsub(/\s+$/, '')
		end
	end
	# Print rows lines
	[lines_wrap.size, rows].min.times do |c|
		print lines_wrap[c] + "\r\n"
	end
end

$log = Logger.new('twitbeeb.log')
$log.datetime_format = "%Y-%m-%d %H:%M:%S"
$log.level = Logger::DEBUG

twitter = TwitterOauth.new(CONSUMER_KEY, CONSUMER_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)


def header
	print BLUE + BACKGROUND + WHITE + "EMF" + MAGENTA + "2016     " + CYAN + "Twitbeeb      " + YELLOW + Time.now.strftime('%H:%M') + " \n\r"
	print "\n\r"
end

def twitlist(twitter)
	print RESET_WINS
	print CLS
	header
	print SET_TEXT_WIN + 0.chr + 24.chr + 39.chr + 2.chr

	$log.info("Searching for Tweets")

	# Search Twitter into array
	lines = []
	# Search for the hashtag or for tweets directed at my account
	tweets = JSON.parse(twitter.search("#{SEARCH} OR @#{MY_ACCT}", { 'result_type' => 'recent' }).body)
	$log.debug(tweets)
	tweets['statuses'].each { |res|
		lines << GREEN + "#{clean_text(res['user']['screen_name'])}:" + WHITE + "#{clean_text(res['text'])}"
	}

	if not lines.empty? then
		# Wrap at 39 cols, print 22 lines.
		print_list(lines, 39, 22)
	else
		print "No tweets found\n\r"
	end

	# Prompt
	print ">"
end

def twitlist_alt(twitter)
	print RESET_WINS
	print CLS
	header
	# 40 : ----------------------------------------
	print "TwitBeeb has a twin! Today it is at the\n\r"
	print "RISC OS London Show. Send it a message\n\r"
	print "by tweeting to @burrBeep\n\r"
	print "\n\r"
	print SET_TEXT_WIN + 0.chr + 24.chr + 39.chr + 5.chr

	$log.info("Searching for Tweets")

	# Search Twitter into array
	lines = []
	tweets = JSON.parse(twitter.search("@burrBeep", { 'result_type' => 'recent' }).body)
	$log.debug(tweets)
	tweets['statuses'].each { |res|
		lines << GREEN + "#{clean_text(res['user']['screen_name'])}:" + WHITE + "#{clean_text(res['text'])}"
	}

	# Wrap at 39 cols, print 19 lines.
	print_list(lines, 39, 19)
end


def infopage1
	print RESET_WINS
	print CLS
	header
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	print "\n\r"
	# 40 : ----------------------------------------
	print " This is a BBC B connected to a\n\r"
	print " Raspberry Pi. The displayed tweets\n\r"
	print " are recent matches of a search\n\r"
	print " for \"emfcamp\". Type at the\n\r"
	print " prompt and press the Return\n\r"
	print " key to send a tweet from the\n\r"
	print " @#{MY_ACCT} account. The hashtag\n\r"
	print " #emfcamp is appended for you.\n\r"
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
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print "\n\r"
	print YELLOW + DOUBLE + "          BRISTOL HACKSPACE\n\r"
	print YELLOW + DOUBLE + "          BRISTOL HACKSPACE\n\r"
	print "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print RED + DOUBLE + "H " * 18 + "\n\r"
	print "\n\r"
	print "\n\r"
	print " " * 6 + DOUBLE + YELLOW + FLASH_ON + "PRESS ANY KEY TO TWEET\r\n"
	print " " * 6 + DOUBLE + YELLOW + FLASH_ON + "PRESS ANY KEY TO TWEET\r\n"
end

def logopage1
	print RESET_WINS
	print CLS

	xpm = File.open("emflogo.xpm").readlines

	xpm = xpm[5..-1].map{ |n| n.gsub(/.*"(.+)".*/m, '\1') }
	xpm = xpm.map{ |k| k[2..-1] }

	(xpm.size / 3).times do |y|
		print "\r\n"
		print G_BLUE + BACKGROUND + G_WHITE
		(xpm.first.size / 2).times do |x|
			out = 0
			out += 1 if xpm[(y * 3)][(x * 2)] == "."
			out += 2 if xpm[(y * 3)][(x * 2) + 1] == "."
			out += 4 if xpm[(y * 3) + 1][(x * 2)] == "."
			out += 8 if xpm[(y * 3) + 1][(x * 2) + 1] == "."
			out += 16 if xpm[(y * 3) + 2][(x * 2)] == "."
			out += 64 if xpm[(y * 3) + 2][(x * 2) + 1] == "."
			print (128 + 32 + out).chr
		end
	end
end

def logopage2
	xpm = File.open("emflogo1.xpm").readlines

	xpm = xpm[5..-1].map{ |n| n.gsub(/.*"(.+)".*/m, '\1') }
	xpm = xpm.map{ |k| k[2..-1] }

	(xpm.size / 3).times do |y|
		print "\r\n"
		if y < 14 then
			print G_BLUE + BACKGROUND + G_WHITE
		else
			print G_BLUE + BACKGROUND + G_MAGENTA
		end
		(xpm.first.size / 2).times do |x|
			out = 0
			out += 1 if xpm[(y * 3)][(x * 2)] == "."
			out += 2 if xpm[(y * 3)][(x * 2) + 1] == "."
			out += 4 if xpm[(y * 3) + 1][(x * 2)] == "."
			out += 8 if xpm[(y * 3) + 1][(x * 2) + 1] == "."
			out += 16 if xpm[(y * 3) + 2][(x * 2)] == "."
			out += 64 if xpm[(y * 3) + 2][(x * 2) + 1] == "."
			print (128 + 32 + out).chr
		end
	end
end

def schedpage
	print RESET_WINS
	print CLS
	header

	venues = { 7 => "#{RED}Stage A", 8 => "#{GREEN}Stage B", 9 => "#{BLUE}Stage C", 10 => "#{YELLOW}Workshop 1", 11 => "#{CYAN}Workshop 2" }
	sched = JSON.parse(open('https://www.emfcamp.org/schedule.json').read)
	tn = Time.now
	#tn = Time.parse('2016-08-06 13:35:00')
	lookahead = 30 * 60

	print DOUBLE + YELLOW + "Coming up:\n\r"
	print DOUBLE + YELLOW + "Coming up:\n\r"
	print "\n\r"

	upcoming = sched.select { |k| d = Time.parse(k['start_date']) - tn; d < lookahead and d > 0 }
	     .sort { |a,b| a['start_date'] <=> b['start_date'] }
	     .map do |e|
			mins = (Time.parse(e['start_date']) - tn).to_i / 60
			if mins == 0 then
				"#{GREEN}   NOW in #{clean_text(e['venue'])} :#{WHITE}#{clean_text(e['title'])}\n\r"
			else
				"#{GREEN}%2d %s in #{clean_text(e['venue'])} :#{WHITE}#{clean_text(e['title'])}\n\r" % [mins, mins == 1 ? "min " : "mins"]
			end
	end

	if upcoming.empty? then
		print "\n\r"
		print "\n\r"
		print "\n\r"
		print " " * 9 + DOUBLE + MAGENTA + FLASH_ON + "PLEASE STAND BY\r\n"
		print " " * 9 + DOUBLE + MAGENTA + FLASH_ON + "PLEASE STAND BY\r\n"
	else
		print_list(upcoming, 39, 19)
	end	
end

$log.info("Starting")

readstr = ""
dispcounter = 0

# Delays for rotating between screens
DISP_TWIT1 = 0
DISP_TWIT2 = 200
DISP_INFO1 = 800
DISP_LOGO1 = 1200
DISP_LOGO2 = 1300
DISP_SCHED = 1400
DISP_RESET = 2000

# Display thread
Thread.new do
	while true do
		#STDERR.print "\r#{dispcounter} #{readstr.inspect}"
		if readstr == "" then
			dispcounter = 0 if dispcounter >= DISP_RESET
			twitlist(twitter) if dispcounter == DISP_TWIT1
			twitlist(twitter) if dispcounter == DISP_TWIT2
			infopage1 if dispcounter == DISP_INFO1
			logopage1 if dispcounter == DISP_LOGO1
			logopage2 if dispcounter == DISP_LOGO2
			schedpage if dispcounter == DISP_SCHED
			dispcounter += 1
		end
		sleep 0.1
	end
end

old_time = Time.now

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
		#now_time = Time.now
		#if now_time - old_time >= 1 then
		#	print MOVE_TEXT_CURSOR + 28.chr + 0.chr
		#	print now_time.strftime('%H:%M:%S')
		#	print MOVE_TEXT_CURSOR + 1.chr + 24.chr
		#	old_time = now_time
		#end
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

		readstr << SUFFIX if not readstr.match(/#{SUFFIX}$/)
		$log.info("Tweeting: #{readstr}")

		twitter_out = twitter.tweet_geo(readstr, LAT, LONG).body
		$log.info("Twitter says: #{twitter_out}")

		sleep 5
	end

end
