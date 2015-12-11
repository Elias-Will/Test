require 'json'
require 'optparse'

$address = "https://kupferwerk.atlassian.net/rest/api/latest/issue"

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
	user = $stdin.gets.chomp
	return $user
end

def curlCreateIssue(data)
	puts `curl -D- -u #{$user} -X POST --data '#{data}' -H \
			"Content-Type: application/json" #{$address}`
end

files = "*_create.json"
$user = getUser() unless $user != nil
Dir[files].each do |f|
	create_hash = File.read(f)
	curlCreateIssue(create_hash)
end