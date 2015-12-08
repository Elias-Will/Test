require 'json'

def getUser()
	puts "Enter username:password"
	print "> "
	user = $stdin.gets.chomp
	return user
end

def curlSearchSerial_Header(user, serial)
	puts `curl -D- -u #{user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = AM AND \\\"Serial Number\\\" ~ #{serial}","fields":["key"]}' \
			"https://kupferwerk.atlassian.net/rest/api/latest/search" > http_header.txt`
end

def curlSearchIMEI_Header(user, imei)
	puts `curl -D- -u #{user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = AM AND \\\"IMEI\\\" ~ #{imei}","fields":["key"]}' \
			"https://kupferwerk.atlassian.net/rest/api/latest/search" > http_header.txt`
end

def checkHeader()
	file = File.read("http_header.txt")
	if file.include?("HTTP/1.1 200 OK")
		return true
	elsif file.include?("HTTP/1.1 401 Unauthorized")
		puts "Unauthorized User!"
	elsif file.include?("HTTP/1.1 502 Bad Gateway")
		puts "Bad Gateway"
	else
		puts "HTTP Error"
	end
	return false
end

def curlSearchSerial(user, serial)
	puts `curl -u #{user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = AM AND \\\"Serial Number\\\" ~ #{serial}","fields":["key"]}' \
			"https://kupferwerk.atlassian.net/rest/api/latest/search" \
			| python -m json.tool > search_result.json`
end

def curlSearchIMEI(user, imei)
	puts `curl -u #{user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = AM AND \\\"IMEI\\\" ~ #{imei}","fields":["key"]}' \
			"https://kupferwerk.atlassian.net/rest/api/latest/search" \
			| python -m json.tool > search_result.json`
end

def checkMatch()
	file = File.read("search_result.json")
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
	file = File.read("search_result.json")
	data = JSON.parse(file)
	return data["issues"][0]["key"]
end

def createPostHash(csv_hash, count)
	new_hash = {
			"fields" => {
				"project" => {
					"key" => "AM" #["Project Name"]
				},
				"summary" => "...", #issue name
				"description" => csv_hash["Model"], #beschreibung
				"issuetype" => {
					"name" => csv_hash["IssueType"] #laptop/iphone/ipad....
				},
				"customfield_11003" => csv_hash["manufacturer"],
				"customfield_11018" => csv_hash["OS"],
				"customfield_11022" => csv_hash["CPU Model"],
				"customfield_11023" => csv_hash["CPU Speed"].to_f,
				"customfield_11060" => csv_hash["Display Resolution"],
				"customfield_11029" => csv_hash["Internal Storage Capacity"].to_f,
				"customfield_11056" => csv_hash["MAC Address (Bluetooth)"],
				"customfield_11054" => csv_hash["MAC Address (WiFi)"],
				"customfield_11004" => csv_hash["Model"],
				"customfield_11019" => csv_hash["OS Version"],
				"customfield_11002" => csv_hash["Serial Number"],
				"customfield_11201" => csv_hash["IMEI"]
			}
		}		
		new_hash = JSON.pretty_generate(new_hash)		
		new_hash = new_hash.gsub(/\s+/, "")		
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
	user = getUser()
	#user = "elias.will:Kappa123k"
	files = "*" + "_" + "*" + "_hash.json"
	count = 0
	Dir[files].each do |f|
		count += 1
		hash_file = File.read(f)
		hash_file = JSON.parse(hash_file)
		found_serial = false
		found_imei = false		

		#
		if hash_file.has_key?("Serial Number") && hash_file["Serial Number"] != nil
			asset_serial = hash_file["Serial Number"]
			#curlSearchSerial_Header(user, asset_serial)
			if state = checkHeader()
				#curlSearchSerial(user, asset_serial)
				found_serial = checkMatch()
				if found_serial
					key = getKey()
				end
			end
		end

		if hash_file.has_key?("IMEI") && hash_file["IMEI"] != nil
			asset_imei = hash_file["IMEI"]
			#curlSearchIMEI_Header(user, asset_imei)
			if state = checkHeader()
				#curlSearchIMEI(user, asset_imei)
				found_imei = checkMatch()
				if found_imei
					key = getKey()
				end
			end
		end		

		if !(found_serial) && !(found_imei)
			createPostHash(hash_file, count)
		else
			createUpdateHash(key, asset_serial, asset_imei, count)
		end
	end

	if user != nil		
		puts `ruby createJira.rb #{user}`
	else
		puts `ruby createJira.rb`
	end
end

main()

=begin
	
HTTP/1.1 401 Unauthorized   wrong username/password
HTTP/1.1 502 Bad Gateway	wrong url
HTTP/1.1 200 OK				successful request

=end