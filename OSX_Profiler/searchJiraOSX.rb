require 'json'
require 'optparse'

def getUser()
	puts "Enter username:password"
	print "> "
	user = $stdin.gets.chomp
	return user
end

def defaultAddress()
	def_protocol = "https://"
	def_host = "kupferwerk.atlassian.net"
	def_file = "/rest/api/latest"
	def_mode = "/search"
	return def_protocol + def_host + def_file + def_mode
end

$jira_project = "TSAM"
$address = defaultAddress()
$user = nil
$output_file_h = "http_header.txt"
$output_file = "search_result.json"

op = OptionParser.new do |opts|
	#opts.banner = ""
	#opts.on('-p')
	#opts.on('-H')
	#opts.on('-m')
	#opts.on('', '--OUT_H')
	#opts.on('', '--OUT')
	opts.on('-a', '--address ad', 'curl Address') {|ad| $address = ad}
	opts.on('-u', '--user user', 'Username & Password') {|user| $user = user}
	#opts.on('-P', '--project pr', 'Jira Project') {|pr| $jira_project = pr}
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def curlSearch_Header(matching_mode, matching_value)
	puts `curl -D- -u #{$user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = #{$jira_project} AND \\\"#{matching_mode}\\\" ~ #{matching_value}","fields":["key"]}' \
			\"#{$address}\" > #{$output_file_h}`
end

def checkHeader()
	file = File.read($output_file_h)
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

def curlSearch(matching_mode, matching_value)
	puts `curl -u #{$user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = #{$jira_project} AND \\\"#{matching_mode}\\\" ~ #{matching_value}","fields":["key"]}' \
			\"#{$address}\" | python -m json.tool > #{$output_file}`
end

def checkMatch()
	file = File.read($output_file)
	data = JSON.parse(file)

	if data["total"] == 0
		return false
	elsif data["total"] == 1
		return true
	elsif data["total"] > 1
		puts "Found more than 1 matching Issues"
	end
end

def getKey()
	file = File.read($output_file)
	data = JSON.parse(file)
	return data["issues"][0]["key"]
end

def createPostHash(csv_hash, count)
	new_hash = {
			"fields" => {
				"project" => {
					"key" => csv_hash["Project Name"] #["Project Name"]
				},
				"summary" => csv_hash["Model"], #issue name
				"description" => csv_hash["Model"], #beschreibung
				"issuetype" => {
					"name" => csv_hash["IssueType"] #laptop/iphone/ipad....
				},
				"customfield_11061" => csv_hash["Battery Capacity"].to_f,
				"customfield_11003" => {"value" => csv_hash["manufacturer"]},
				"customfield_11018" => {"value" => csv_hash["OS"]},
				"customfield_11027" => csv_hash["CPU Cores"].to_f,
				"customfield_11022" => csv_hash["CPU Model"],
				"customfield_11023" => csv_hash["CPU Speed"].to_f,
				"customfield_11060" => csv_hash["Display Resolution"],
				"customfield_11044" => csv_hash["Firewire Ports"].to_f, #new
				"customfield_11057" => csv_hash["Graphics Card 1"], #new
				"customfield_11058" => csv_hash["Graphics Card 2"], #new
				
				"customfield_11029" => csv_hash["Internal Storage Capacity"].to_f,
				"customfield_11056" => csv_hash["MAC Address (Bluetooth)"],
				"customfield_11055" => csv_hash["MAC Address (Ethernet)"], #new
				"customfield_11054" => csv_hash["MAC Address (WIFI)"],
				"customfield_11004" => csv_hash["Model"],
				"customfield_11038" => csv_hash["Number of Thunderbolt Ports"].to_f, #new
				"customfield_11019" => csv_hash["OS Version"],
				"customfield_11042" => csv_hash["Power Supply (Energy)"].to_f, #new
				"customfield_11024" => csv_hash["RAM"],
				#RAM Speed
				#RAM Upgradeable
				"customfield_11002" => csv_hash["Serial Number"],
				"customfield_11040" => {"value" => csv_hash["Thunderbolt Type"]}, #new
				"customfield_11037" => {"value" => csv_hash["USB Type"]}, #new
				"customfield_11059" => csv_hash["VRAM"].to_f #new
			}
		}
		if new_hash["fields"]["customfield_11061"] == 0.0
			new_hash["fields"].delete("customfield_11061")
		end
		if new_hash["fields"]["customfield_11027"] == 0.0
			new_hash["fields"].delete("customfield_11027")
		end
		if new_hash["fields"]["customfield_11023"] == 0.0
			new_hash["fields"].delete("customfield_11023")
		end
		if new_hash["fields"]["customfield_11029"] == 0.0
			new_hash["fields"].delete("customfield_11029")
		end	
		if new_hash["fields"]["customfield_11044"] == 0.0
			new_hash["fields"].delete("customfield_11044")
		end
		if new_hash["fields"]["customfield_11038"] == 0.0
			new_hash["fields"].delete("customfield_11038")
		end
		if new_hash["fields"]["customfield_11042"] == 0.0
			new_hash["fields"].delete("customfield_11042")
		end
		if new_hash["fields"]["customfield_11059"] == 0.0
			new_hash["fields"].delete("customfield_11059")
		end
		if new_hash["fields"]["customfield_11003"]["value"] == nil
			new_hash["fields"].delete("customfield_11003")
		end
		if new_hash["fields"]["customfield_11018"]["value"] == nil
			new_hash["fields"].delete("customfield_11018")
		end
		if new_hash["fields"]["customfield_11040"]["value"] == nil
			new_hash["fields"].delete("customfield_11040")
		end
		if new_hash["fields"]["customfield_11037"]["value"] == nil
			new_hash["fields"].delete("customfield_11037")
		end




		
		new_hash = JSON.pretty_generate(new_hash)		
		new_hash = new_hash.gsub(/\n/, "")
		new_hash = new_hash.gsub(/:\s+/, ":")
		new_hash = new_hash.gsub(/\{\s+/, "{")
		new_hash = new_hash.gsub(/\s+}/, "}")
		new_hash = new_hash.gsub(/,\s+/, ",")
		hash_file = File.open(count.to_s + "_create.json", "w")
		hash_file.write(new_hash)
		hash_file.close
end

def createUpdateHash(key, serial, imei, count)
	new_hash = {
		"key" => key,
		"serial" => serial,
		"imei" => imei
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
		found_imei = false
		hash_file.has_key?("Serial Number") ? asset_serial = hash_file["Serial Number"] : asset_serial = nil
		hash_file.has_key?("IMEI") ? asset_imei = hash_file["IMEI"] : asset_imei = nil

		$jira_project = hash_file["Project Name"]
		if hash_file.has_key?("Serial Number") && hash_file["Serial Number"] != nil
			curlSearch_Header("Serial Number", asset_serial)
			if state = checkHeader()
				curlSearch("Serial Number", asset_serial)
				found_serial = checkMatch()
				if found_serial
					key = getKey()
					#next
				end
			end
		end

		if hash_file.has_key?("IMEI") && hash_file["IMEI"] != nil
			curlSearch_Header("IMEI", asset_imei)
			if state = checkHeader()
				curlSearch("IMEI", asset_imei)
				found_imei = checkMatch()
				if found_imei
					key = getKey()
				end
			end
		end		

		if !(found_serial) && !(found_imei)
			if state
				createPostHash(hash_file, count)
			end
		else
			createUpdateHash(key, asset_serial, asset_imei, count)
		end
	end	
end

main()

=begin
	
HTTP/1.1 401 Unauthorized   wrong username/password
HTTP/1.1 502 Bad Gateway	wrong url
HTTP/1.1 200 OK				successful request

=end