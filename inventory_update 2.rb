require 'json'
require 'optparse'

def getDirectory()
	return Dir.pwd
end

$user = nil
$serial_number = nil
$imei = nil
$project_key = "TSAM"
$script_directory = getDirectory()
$search_address = "https://kupferwerk.atlassian.net/rest/api/latest/search"
$update_address = "https://kupferwerk.atlassian.net/rest/api/latest/issue/"
$search_response_file = "i_search_response.json"
$update_response_file = "i_update_response.json"
$header_response_file = "i_header_response.txt"
$issue_file = "i_query.json"

op = OptionParser.new do |opts|
	opts.on('-p', '--project p', 'Jira Project Key') { |p| $project_key = p }
	opts.on('-u', '--user u', 'User Name & Password <user.name:Password>') { |u| $user = u }
	opts.on('-i', '--imei i', 'Input IMEI') { |i| $imei = i }
	opts.on('-s', '--serial s', 'Input Serial Number (no S pre-fix)') { |s| $serial_number = s }
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def getUser()
	puts "### Enter username <user.name:Password>"
	print "> "
	user = $stdin.gets.chomp
	return user
end

def parseJson(file)
	return false if !file.include?(".json")
	f_file = File.read(file)
	f_data = JSON.parse(f_file)
	return f_data
end


def getNumber()
	puts "### Enter Serial Number/IMEI"
	print "> "
	number = $stdin.gets.chomp
	number.size > 13 ? $imei = number : $serial_number = number
end

def curlSearch_Header(mode, value)
	puts `curl -D- -u #{$user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = #{$project_key} AND \\\"#{mode}\\\" ~ #{value}","fields":["key"]}' \
			\"#{$search_address}\" > #{$header_response_file}`
end

def checkHeader()
	file = File.read($header_response_file)
	if file.include?("HTTP/1.1 200 OK")
		return true
	elsif file.include?("HTTP/1.1 401 Unauthorized")
		#puts "Unauthorized User!"
	elsif file.include?("HTTP/1.1 502 Bad Gateway")
		#puts "Bad Gateway"
	else
		#puts "HTTP Error"
	end
	return false
end

def curlSearch(mode, value)
	puts `curl -u #{$user} -X POST -H "Content-Type: application/json"\
	 --data '{"jql":"project = #{$project_key} AND \\\"#{mode}\\\" ~ #{value}","fields":["key","Asset Number"]}'\
	  #{$search_address} | python -m json.tool > #{$search_response_file}`
end

def curlGetIssue(key)
	puts `curl -u #{$user} #{$update_address}#{key} | python -m json.tool > #{$issue_file}`
end

def curlUpdate(key, data)
	puts `curl -D- -u #{$user} -X PUT --data '#{data}' -H "Content-Type: application/json" \
	#{$update_address}#{key} > #{$update_response_file}`
end

def getCustomfieldID(type)
	
	case type
	when "Serial Number" then return "customfield_11002"
	when "IMEI" then return "customfield_11201"
	else return false
	end
end

def getIssueKey()
	f_data = parseJson($search_response_file)
	return false if !f_data
	if f_data["total"] == 1
		return f_data["issues"][0]["key"]
	else
		return false
	end
end

def getAssetNumber()
	f_data = parseJson($issue_file)
	return false if !f_data
	f_asset_number = f_data["fields"]["customfield_11009"]
	if f_asset_number == nil
		return true
	else
		puts "Issue up-to-date"
		return false
	end
end

def getUpdateFile(file, cf_id)
	f_data = parseJson(file)
	return false if !f_data
	if f_data.has_key?(cf_id)
		if f_data[cf_id] == $serial_number
			return f_data["customfield_11009"]
		elsif f_data[cf_id] == $imei
			return f_data["customfield_11009"]
		end
	else
		return false
	end
end

def getUpdateHash(file)
	f_data = parseJson(file)
	return false if !f_data
	return f_data
end

def main()
	$user = getUser() unless $user != nil
	if $serial_number == nil && $imei == nil
		getNumber()
	end

	curlSearch_Header("IMEI", $imei) if $imei != nil
	curlSearch_Header("Serial Number", $serial_number) if $serial_number != nil
	Kernel.abort("HTTP Error") if !checkHeader()
	curlSearch("IMEI", $imei) if $imei != nil	
	curlSearch("Serial Number", $serial_number) if $serial_number != nil
	
	issue_key = getIssueKey()
	Kernel.abort("No Issue Found") if !issue_key
	curlGetIssue(issue_key)
	asset_number = getAssetNumber()
	Kernel.abort("Asset Number Problem") if !asset_number
	if asset_number
		Dir.chdir("..") do		
			#inventory_directory = inventory_directory + "/inventory_json"
			#puts inventory_directory
			inventory_directory = Dir.pwd
			cf_ID = getCustomfieldID("Serial Number") if $serial_number != nil
			cf_ID = getCustomfieldID("IMEI") if $imei != nil
			Kernel.abort("CF_ID error") if !cf_ID
			asset_found = false
			Dir[inventory_directory + "/*_match.json"].each do |match|
				local_asset = getUpdateFile(match, cf_ID)
				next if !local_asset || local_asset == nil
				asset_found = true
			end
			if asset_found
				hash_file = inventory_directory + "/" + local_asset + "_curl.json"
				hash_data = getUpdateHash(hash_file)
				curlUpdate(issue_key, hash_data)
			else
				Kernel.abort("Nothing was updated")
			end
		end
	end
	puts "####### " + key + " was updated!"
end

main()