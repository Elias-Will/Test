require 'json'
require 'optparse'
require '../curl_commands'

op = OptionParser.new do |opts|
	opts.banner = "jira_create_ios.rb"
	#opts.on('-d', '--default', 'Default parameters') { }
	opts.on('-u', '--user user', 'Username') { |user| $user = user }
	opts.on('-f', '--file file', 'Set Input File') { |file| $create_files = file }
	#opts.on('-a', '--address -adr', 'Address') { |adr| $address = adr }
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def set_jira_user()
	puts "Enter username:password"
	print "> "
	$user = $stdin.gets.chomp
end

def set_create_files()
	$create_files = "*_create.json"
end

set_create_files() unless $create_files != nil
set_jira_user() unless $user != nil
Dir[$create_files].each do |file|
	create_hash = File.read(file)
	CurlCommand.curl_create_issue($user, create_hash)
end