require 'json'
require 'optparse'
require '../hash_formatter'
require '../curl_commands'

op = OptionParser.new do |opts|
	opts.banner = "jira_update_osx.rb"
	opts.on('-u', '--user user', 'User') { |user| $user = user }
	opts.on('-f', '--file file', 'Set Input File') { |file| $update_files = file }
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

def set_update_files()
	$update_files = "*_update.json"
end

set_update_files() unless $update_files != nil
set_jira_user() unless $user != nil
Dir[$update_files].each do |file|
	link_hash = CreateHash.read_hash_file(file)

	asset_hash_file = Dir.glob("*hash.json").first
	asset_hash = CreateHash.read_hash_file(asset_hash_file)

	jira_key = link_hash["key"]
	CurlCommand.curl_single_issue($user, jira_key)
	curl_response_hash = CreateHash.read_hash_file("current_issue.json")
	
	update_hash = CompareHashes.compare_hashes(asset_hash, curl_response_hash)	
	break if update_hash == nil
	update_hash = HashFormatter.delete_blanks(update_hash)
	update_hash = JSON.pretty_generate(update_hash)
	update_hash = HashFormatter.remove_spaces(update_hash)
	update_hash = HashFormatter.add_escapes(update_hash)	
	CurlCommand.curl_update_issue($user, update_hash, jira_key)
end
