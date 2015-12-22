require 'json'
require 'optparse'
require '../curl_commands'

op = OptionParser.new do |opts|
	#opts.banner = ""
	opts.on('-d', '--default', 'Default parameters') { }
	opts.on('-u', '--user user', 'Username') { |user| $user = user }
	opts.on('-a', '--address -adr', 'Address') { |adr| $address = adr }
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def getUser()
	puts "Enter username:password"
	print "> "
	$user = $stdin.gets.chomp
	return $user
end

files = "*_create.json"
$user = getUser() unless $user != nil
Dir[files].each do |f|
	create_hash = File.read(f)	
	CurlCommands.curlCreateIssue($user, create_hash)
end