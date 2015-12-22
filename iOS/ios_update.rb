require 'json'
require 'optparse'
require '../hash_formatter'
require '../curl_commands'

$user = nil
op = OptionParser.new do |opts|
	opts.on('-u', '--user user', 'User') { |user| $user = user }
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

$user = getUser() unless $user != nil
files = "*update.json"
Dir[files].each do |f|
	puts f
	_file = File.read(f)
	jira_location_hash = JSON.parse(_file)
	hash_file = Dir.glob("*hash.json").first
	_file = File.read(hash_file)
	new_hash = JSON.parse(_file)

	key = jira_location_hash["key"]
	CurlCommands.curlSingleIssue($user, key)

	curl_file = File.read("current_issue.json")
	current_hash = JSON.parse(curl_file)

	
	update_hash = CompareHashes.compare_hashes(new_hash, current_hash)
	break if update_hash == nil
	update_hash = HashFormatter.delete_blanks(update_hash)
	update_hash = JSON.pretty_generate(update_hash)
	update_hash = HashFormatter.remove_spaces(update_hash)
	update_hash = HashFormatter.add_escapes(update_hash)

	CurlCommands.curlUpdateIssue($user, update_hash, key)
end

