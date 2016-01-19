require 'json'
require 'optparse'
require '../asset_management/curl_commands'
require '../asset_management/hash_formatter'

$asset_directory = "./JSON/"

op = OptionParser.new do |opts|
	#opts.banner = ""
	opts.on('-d', '--default', 'Default valus') { 
		$jira_project = "AM"
		$asset_directory = "./JSON/" }
	opts.on('-u', '--user user', 'Set Jira User') { |user| $user = user }
	opts.on('-p', '--project project', 'Set Jira Porject') { |project| $jira_project = project }
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
	puts "### Directory (default is ./JSON/)"
	print "> "
	$asset_directory = $stdin.gets.chomp
end
	
def set_jql_input()
	puts "Enter field(s) and value(s) for jql search!"
	puts "Example: AND \"Serial Number\" ~ <serial>"
	puts "Automatically adds <\"Asset Number\" is EMPTY> at the end."

	print "> "
	jql = $stdin.gets.chomp
	jql += " AND \"Asset Number\" is EMPTY"
	jql = HashFormatter.add_escapes(jql.to_s) #works for String as well
	return jql
end

def set_jql_max_results()
	puts "Maximum amount of keys that get returned from Jira"
	puts "Keep empty for default (50)"
	print "> "
	max_results = $stdin.gets.chomp
	return max_results.to_f
end

def get_jql_search_hash()
	return CreateHash.read_hash_file($output_file_jql)
end

def get_jql_search_result()
	return CurlResponse.check_search_result($output_file_jql)
end

### 	Pulls Jira Issues from jql-search
def get_jira_issue(jql_hash, index)
	key = jql_hash["issues"][index]["key"].to_s
	puts "pulling Jira issue #{key}..."
	CurlCommand.curl_single_issue_jql($user, key, "ISSUE/" + key + ".json")
	issue_path = Dir.pwd
	issue_directory = issue_path + "/ISSUE/" + key + ".json"
	puts "Jira Issue saved to #{issue_directory}"
	puts "#######################################", ""
end

def get_jira_serial(hash)
	return hash["fields"]["customfield_11002"]
end

def get_jira_imei(hash)
	return hash["fields"]["customfield_11201"]
end

def get_jira_key(hash)
	return hash["key"]
end

### 	This kind of formatting should be done in create_json.rb.
### 	Create hash like new_hash + Serial Number and then
### 	delete Serial Number before pusing hash to CreateHash
### 	and HashFormatter.
def set_update_values(link_hash)
	hash = CreateHash.read_hash_file(link_hash["asset"])
	new_hash = {}
	new_hash.store("Asset Number", hash["fields"]["Asset Number"])
	new_hash.store("Purchase Date", hash["fields"]["Purchase Date"])
	new_hash.store("Purchase Cost", hash["fields"]["Purchase Cost"])
	new_hash.store("Supplier", hash["fields"]["Supplier"])
	new_hash.store("Order Number", hash["fields"]["Order Number"])
	return new_hash
end

### 	Creates hash for curl request
def update_jira_issue(link_hash)
	new_hash = set_update_values(link_hash)
	post_hash = CreateHash.create_post_hash(new_hash, nil)
	post_hash = JSON.pretty_generate(post_hash)
	post_hash = HashFormatter.remove_spaces(post_hash)
	post_hash = HashFormatter.add_escapes(post_hash)
	CurlCommand.curl_update_issue($user, post_hash, link_hash["jira"])
	return true
end

### 	The check_search_result function returns 'true' when
### 	the jql search yields exactly 1 result, 'false' in case
### 	of 0 results and for >1 results the amount.
def get_loop_count(jql_response_amount)
	if jql_response_amount == true
		return 0
	elsif jql_response_amount == false
		Kernel.abort("Nothing was found...")
	elsif jql_response_amount > 0
		return jql_response_amount - 1
	else
		Kernel.abort("Nothing was found...")
	end
end

def cleanup()
	puts "delete pulled files? (y/n)"
	if $stdin.gets.chomp == "y"
		puts `rm ISSUE/*.json`
	end
end

def main()
	### 	JQL-Search
	jql_input = set_jql_input()
	jql_max_results = set_jql_max_results()
	jql_max_results = 50 if jql_max_results == 0.0 #in case of no input
	CurlCommand.curl_multiple_issues_jql($user, $jira_project, jql_input, jql_max_results)
	jql_response_amount = CurlResponse.check_search_result($output_file_jql)
	Kernel.abort("Nothing was found") if jql_response_amount == false
	jql_response_amount = 1 if jql_response_amount == true

	jql_response_hash = CreateHash.read_hash_file($output_file_jql)
	jql_response_amount = jql_max_results if jql_response_amount > jql_max_results

	### 	Pulling Individual Issues from JQL-Search
	n = get_loop_count(jql_response_amount)
	for i in 0..n
		get_jira_issue(jql_response_hash, i)
	end

	### 	Comparing Search Results to Local Inventory
	jira_files = "ISSUE/*.json"
	Dir[jira_files].each do |jira_file|
		issue_hash = CreateHash.read_hash_file(jira_file) #hash from Jira Issue
		next if issue_hash["fields"]["customfield_11009"] != nil #already up-to-date
		jira_serial = get_jira_serial(issue_hash)
		jira_imei = get_jira_imei(issue_hash)

		#local_files = "./JSON/*.json"
		local_files = $asset_directory + "*.json"
		Dir[local_files].each do |local_file|
			asset_hash = CreateHash.read_hash_file(local_file) #hash from local inventory
			asset_serial = asset_hash["fields"]["Serial Number"]
			next if asset_serial == nil #serial (imei) required to look for matching issue
			jira_serial_alt = "S" + jira_serial.to_s #s/n sometimes has 'S' pre-fix on invoice
			if asset_serial == jira_serial || asset_serial == jira_imei || asset_serial == jira_serial_alt
				link_hash = {
					"jira" => get_jira_key(issue_hash),
					"asset" => local_file
				}
				puts link_hash
				break if update_jira_issue(link_hash) #returns true after update (not checking for success, yet)
			end
		end
	end
	cleanup()
end

set_jira_user() unless $user != nil
set_jira_project() unless $jira_project != nil
set_asset_directory() unless $asset_directory != nil
main()