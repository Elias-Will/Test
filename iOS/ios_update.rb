require 'json'
require 'optparse'
require '../hash_formatter'

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

def curlSingleIssue(key)
	puts `curl -u #{$user} https://kupferwerk.atlassian.net/rest/api/latest/issue/#{key}?expand=renderedFields | python -m json.tool > ./current_issue.json`
end

def curlUpdateIssue(key, data)
	puts `curl -D- -u #{$user} -X PUT --data "#{data}" -H "Content-Type: application/json" https://kupferwerk.atlassian.net/rest/api/latest/issue/#{key} > update_log.txt`
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
	curlSingleIssue(key)

	curl_file = File.read("current_issue.json")
	current_hash = JSON.parse(curl_file)

	
	update_hash = CompareHashes.compare_hashes(new_hash, current_hash)
	break if update_hash == nil
	update_hash = HashFormatter.delete_blanks(update_hash)
	update_hash = JSON.pretty_generate(update_hash)
	update_hash = HashFormatter.remove_spaces(update_hash)
	update_hash = HashFormatter.add_escapes(update_hash)

	curlUpdateIssue(key, update_hash)
end

