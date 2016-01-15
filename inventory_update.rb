require 'json'
require 'optparse'
require './asset_management/curl_commands'
require './asset_management/hash_formatter'

op = OptionParser.new do |opts|
	#opts.banner = ""
	opts.on('-d', '--default', 'Default valus') { 
		$jira_project = "AM"
		$asset_directory = "./inventory_json/" }
	opts.on('-u', '--user user', 'Set Jira User') { |user| $user = user }
	opts.on('-h', '--help', 'Display Options') { puts opts; exit }
end
op.parse!

def set_jira_user()
	puts "### user.name:password"
	print "> "
	$user = $stdin.gets.chomp
end

def set_jira_project()
	puts "### Jira Project"
	print "> "
	$jira_project = $stdin.gets.chomp
end

def set_asset_directory()
	puts "### Directory"
	print "> "
	$asset_directory = $stdin.gets.chomp
end
	
def get_jql_input()
	puts "Enter field(s) and value(s) for jql search!"
	puts "Example: AND \"Serial Number\" ~ <serial> AND \"Asset Number\" is EMPTY"

	print "> "
	jql = $stdin.gets.chomp
	jql = HashFormatter.add_escapes(jql.to_s) #works for String as well
	return jql
end

def get_jql_search_hash()
	return CreateHash.read_hash_file($output_file_jql)
end

def get_jql_search_result()
	return CurlResponse.check_search_result($output_file_jql)
end

def main()

	### 	JQL-Search
	jql_input = get_jql_input()
	CurlCommand.curl_multiple_issues_jql($user, $jira_project, jql_input)
	jql_response_amount = CurlResponse.check_search_result($output_file_jql)
	jql_response_hash = CreateHash.read_hash_file($output_file_jql) unless jql_response_amount == false
	##################

	puts jql_response_amount if jql_response_amount == false #for debugging
	Kernel.abort("nothing found") if jql_response_amount == false

	### 	Individual Issues from JQL-Search
	n = jql_response_amount - 1
	for i in 0..n
		key = jql_response_hash["issues"][i]["key"].to_s
		puts "pulling Jira issue #{key}..."
		CurlCommand.curl_single_issue_jql($user, key, key + ".json")
		issue_path = Dir.pwd
		issue_directory = issue_path + "/" + key + ".json"
		puts "Jira Issue saved to #{issue_directory}"
		puts "#######################################", ""
	end
	##################

	### 	Read Serial/IMEI
	files = "AM-*.json"
	Dir[files].each do |file|
		issue_hash = CreateHash.read_hash_file(file)
		issue_type = issue_hash["fields"]["issuetype"]["name"]
		if issue_type == "iPhone" || issue_type == "Android Phone"
			puts issue_type
			puts issue_hash["fields"]["customfield_11002"], issue_hash["fields"]["customfield_11201"]
		else
			puts issue_type
			puts issue_hash["fields"]["customfield_11002"]
		end
	end
end

set_jira_user() unless $user != nil
set_jira_project() unless $jira_project != nil
set_asset_directory() unless $asset_directory != nil
main()