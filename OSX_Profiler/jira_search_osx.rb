require 'json'
require 'optparse'
require '../hash_formatter'
require '../curl_commands'

$jira_project = "TSAM"
$user = nil
$input_files = nil

def get_jira_user()
	puts "Enter username:password"
	print "> "
	$user = $stdin.gets.chomp
end

def get_input_files()
	$input_files = "*" + "_" + "*" + "_hash.json"
end

op = OptionParser.new do |opts|
	opts.banner = "### jira_search_osx.rb ###"	
	#opts.on('-a', '--address ad', 'curl Address') {|ad| $address = ad}
	opts.on('-f', '--file file', 'Set Input File') { |file| $input_files = file }
	opts.on('-u', '--user user', 'Username & Password') {|user| $user = user}
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def set_jira_user()
	get_jira_user() unless $user != nil
end

def set_input_files()
	get_input_files() unless $input_files != nil
end

def get_jira_issue_key()	
	search_result_data = CreateHash.read_hash_file($output_file_search)
	return search_result_data["issues"][0]["key"]
end

def create_post_hash(asset_hash, file_count)		
	post_hash = CreateHash.create_osx_header(asset_hash)
	post_hash = CreateHash.create_post_hash(asset_hash, post_hash)
	post_hash = HashFormatter.delete_blanks(post_hash)
	post_hash = JSON.pretty_generate(post_hash)
	post_hash = HashFormatter.remove_spaces(post_hash)
	file_name = file_count.to_s + "_create.json"
	CreateHash.create_hash_file(file_name, post_hash)
end

def create_link_hash(jira_key, asset_serial, file_count)
	link_hash = CreateHash.create_link_hash(jira_key, asset_serial)
	link_hash = JSON.pretty_generate(link_hash)
	file_name = file_count.to_s + "_update.json"
	CreateHash.create_hash_file(file_name, link_hash)
end

def main()
	file_count = 0
	Dir[$input_files].each do |file|
		file_count += 1 #required for unique naming of hash files
		found_jira_match = false #determines whether 'create' or 'update' request is needed

		asset_hash = CreateHash.read_hash_file(file)
		asset_hash.has_key?("Serial Number") ? asset_serial = asset_hash["Serial Number"] : asset_serial = nil
		$jira_project = asset_hash["Project Name"]
		if asset_serial != nil
			CurlCommand.curl_search_header($user, $jira_project, "Serial Number", asset_serial)
			curl_request_success = CurlResponse.check_search_result_header($output_file_h)
			if curl_request_success
				CurlCommand.curl_search($user, $jira_project, "Serial Number", asset_serial)
				found_jira_match = CurlResponse.check_search_result($output_file_search)
				if found_jira_match
					jira_issue_key = get_jira_issue_key()					
				end
			end
		end			

		if !(found_jira_match)
			if curl_request_success
				create_post_hash(asset_hash, file_count)
			end
		else
			create_link_hash(jira_issue_key, asset_serial, file_count)
		end
	end	
end

set_jira_user()
set_input_files()
main()
