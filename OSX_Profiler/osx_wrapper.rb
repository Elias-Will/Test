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
	opts.banner = "Usage: osx_wrapper.rb [opts]"
	# opts.on('-d', '--default', 'Default parameters') {
	# 	$default = true
	# }
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
	`ruby jira_read_csv.rb`
    `ruby jira_search_osx.rb #{$curl_jira_m}`
	#`ruby jira_create_osx.rb #{$curl_jira_m}`
else
	puts "### Reading CSV File ###"
	#puts `ruby jira_read_csv.rb -h`
	#print "> "
	#$r_csv_m += $stdin.gets.chomp
	$r_csv_m += "-a "
	`ruby jira_read_csv.rb #{$r_csv_m}`

	puts "### Searing Jira Issue ###"
	#$address = $protocol + $host + $file + "/search"
	$s_jira_m += "-u #{$user} "
	#$s_jira_m += "-a #{$address} "
	#$s_jira_m += "-P #{$project} "
	#puts `ruby jira_search_osx.rb -h`
	#puts $s_jira_m
	#print "> "
	#$s_jira_m += $stdin.gets.chomp
	`ruby jira_search_osx.rb #{$s_jira_m}`

	

	if Dir.glob("*_create.json").any?
		puts "### Creating Jira Issue ###"
		#$stdin.gets
		#$address = $protocol + $host + $file + "/issue"
		$c_jira_m += "-u #{$user} "
		#$c_jira_m += "-a #{$address} "
		#puts `ruby jira_create_osx.rb -h`
		#puts $c_jira_m
		#print "> "
		#$c_jira_m += $stdin.gets.chomp
		`ruby jira_create_osx.rb #{$c_jira_m}`
	end

	if Dir.glob("*_update.json").any?
		puts "### Checking whether updates are needed ###"
		#$stdin.gets
		$c_jira_m += "-u #{$user} "
		`ruby jira_update_osx.rb #{$c_jira_m}`
	end

	# files = "*" + "_" + "*" + "_hash.json"
	# file = Dir.glob("files").first
	# file = File.read(file)
	# data = JSON.parse(file)
	# serial = data["Serial Number"]

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
	# if File.exist?("http_header.txt")
	# 	`rm http_header.txt`
	# end
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

