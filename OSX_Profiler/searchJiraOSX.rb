require 'json'
require 'optparse'
require '../hash_formatter'
require '../curl_commands'

def getUser()
	puts "Enter username:password"
	print "> "
	user = $stdin.gets.chomp
	return user
end

# def defaultAddress()
# 	def_protocol = "https://"
# 	def_host = "kupferwerk.atlassian.net"
# 	def_file = "/rest/api/latest"
# 	def_mode = "/search"
# 	return def_protocol + def_host + def_file + def_mode
# end

$jira_project = "TSAM"
$user = nil

op = OptionParser.new do |opts|
	opts.banner = "### searchJiraOSX.rb options ###"	
	#opts.on('-a', '--address ad', 'curl Address') {|ad| $address = ad}
	opts.on('-u', '--user user', 'Username & Password') {|user| $user = user}
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def checkHeader()
	file = File.read($output_file_h)
	if file.include?("HTTP/1.1 200 OK")
		return true
	#no proper case-handling possible when using osx_wrapper
	elsif file.include?("HTTP/1.1 401 Unauthorized")
		
	elsif file.include?("HTTP/1.1 502 Bad Gateway")
		
	else
		#puts "HTTP Error"
	end
	return false
end

def checkMatch()
	file = File.read($output_file_search)
	data = JSON.parse(file)

	if data["total"] == 0
		return false
	elsif data["total"] == 1
		return true
	elsif data["total"] > 1
		puts "Found more than 1 matching Issues"
		return true
	end
end

def getKey()
	file = File.read($output_file_search)
	data = JSON.parse(file)
	return data["issues"][0]["key"]
end

def createPostHash(csv_hash, count)
		
		new_hash = CreateHash.create_osx_header(csv_hash)
		new_hash = CreateHash.create_post_hash(csv_hash, new_hash)
		new_hash = HashFormatter.delete_blanks(new_hash)
		new_hash = JSON.pretty_generate(new_hash)
		new_hash = HashFormatter.remove_spaces(new_hash)
		hash_file = File.open(count.to_s + "_create.json", "w")
		hash_file.write(new_hash)
		hash_file.close
end

def createUpdateHash(key, serial, count)
	new_hash = {
		"key" => key,
		"serial" => serial
	}
	new_hash = JSON.pretty_generate(new_hash)
	update_file = File.open(count.to_s + "_update.json", "w")
	update_file.write(new_hash)
	update_file.close	
end

def main()
	$user = getUser() unless $user != nil 
	files = "*" + "_" + "*" + "_hash.json"
	count = 0
	Dir[files].each do |f|
		count += 1
		hash_file = File.read(f)
		hash_file = JSON.parse(hash_file)
		found_serial = false
		hash_file.has_key?("Serial Number") ? asset_serial = hash_file["Serial Number"] : asset_serial = nil
		$jira_project = hash_file["Project Name"]
		if asset_serial != nil
			CurlCommands.curlSearch_Header($user, $jira_project, "Serial Number", asset_serial)
			state = checkHeader()
			if state
				CurlCommands.curlSearch($user, $jira_project, "Serial Number", asset_serial)
				found_serial = checkMatch()
				if found_serial
					key = getKey()
					#next
				end
			end
		end			

		if !(found_serial)
			if state
				createPostHash(hash_file, count)
			end
		else
			createUpdateHash(key, asset_serial, count)
		end
	end	
end

main()
