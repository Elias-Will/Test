#!/usr/bin/env ruby
require 'optparse'

$user = nil
$protocol = "https://"
$host = "kupferwerk.atlassian.net"
$file = "/rest/api/latest"
#$project = "TSAM"
$keep_files = false
$csv_get_all = false
$default = false

$r_csv_m = ""
$curl_jira_m = ""
$s_jira_m = ""
$c_jira_m = ""

op = OptionParser.new do |opts|
	opts.banner = "Usage: android_wrapper.rb [opts]"
	opts.on('-d', '--default', 'Default parameters') {
		$default = true
	}
	opts.on('-p', '--protocol pr', 'Protocol') {|pr| 
		$protocol = pr
	}
	#opts.on('-P', '--project proj', 'Jira Project') { |proj| $project = proj }
	opts.on('-H', '--host host', 'Host') {|host| 
		$host = host
	}
	opts.on('-u', '--user user', 'Username & Password (eg user.name:password)') { |user| $user = user }
	opts.on('-k', '--keep', 'Keep files') { $keep_files = true }
	opts.on('-h', '--help', 'Display Help') do 
		puts opts
		exit
	end	
end
op.parse!

###---------------Username--------------
if $user == nil
	puts "Enter username user.name:password"
	print "> "
	$user = $stdin.gets.chomp
end
puts $user
###---------------------------------------
$curl_jira_m += "-u #{$user} "

if $default
	`ruby readCSV.rb`
    `ruby searchJiraAndroid.rb #{$curl_jira_m}`
	`ruby createJira.rb #{$curl_jira_m}`
else
	# -h -a -e#
	puts "### Reading CSV File ###"
	#puts `ruby readCSV.rb -h`
	#print "> "
	#$r_csv_m += $stdin.gets.chomp
	$r_csv_m += "-a "
	`ruby readCSV.rb #{$r_csv_m}`

	puts "### Searing Jira Issue ###"
	$address = $protocol + $host + $file + "/search"
	$s_jira_m += "-u #{$user} "
	$s_jira_m += "-a #{$address} "
	#$s_jira_m += "-P #{$project} "
	#puts `ruby searchJiraAndroid.rb -h`
	#puts $s_jira_m
	#print "> "
	#$s_jira_m += $stdin.gets.chomp
	`ruby searchJiraAndroid.rb #{$s_jira_m}`

	if Dir.glob("*_create.json").any?
		puts "### Creating Jira Issue ###"
		$address = $protocol + $host + $file + "/issue"
		$c_jira_m += "-u #{$user} "
		$c_jira_m += "-a #{$address} "
		#puts `ruby createJira.rb -h`
		#puts $c_jira_m
		#print "> "
		#$c_jira_m += $stdin.gets.chomp
		`ruby createJira.rb #{$c_jira_m}`
	end

	if Dir.glob("*_update.json").any?
		puts "### Checking whether updates are needed ###"
		$c_jira_m += "-u #{$user} "
		`ruby android_update.rb #{$c_jira_m}`
	end
end

if ! $keep_files
	puts "### Deleting Newly Created Files ###"
	if Dir.glob("*_hash.json").any?
		`rm *_hash.json`
	end
	if Dir.glob("*_create.json").any? 
		`rm *_create.json` 
	end
	if Dir.glob("*_update.json").any?
		`rm *_update.json`
	end
	if File.exist?("http_header.txt")
		`rm http_header.txt`
	end
	if File.exist?("search_result.json")
		`rm search_result.json`
	end
	if File.exist?("current_issue.json")
		`rm current_issue.json`
	end
	if File.exist?("log.txt")
		`rm log.txt`
	end
end
