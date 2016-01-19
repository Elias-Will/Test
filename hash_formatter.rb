module HashFormatter

	### 	Removes all spaces & new lines, except those inside
	### 	of a String value.
	### 	Having emtpy spaces between keys & values and at the
	### 	front & end of a value makes Jira cancle the
	### 	POST or PUT request and return Bad Request.
	def self.remove_spaces(hash)
		hash = hash.gsub(/\n/, "")			#removes new lines
		hash = hash.gsub(/:\s+/, ":")		#removes spaces after :
		hash = hash.gsub(/\{\s+/, "{")		#removes spaces after {
		hash = hash.gsub(/\s+}/, "}")		#removes spaces before }
		hash = hash.gsub(/,\s+/, ",")		#removes spaces after ,
		hash = hash.gsub(/\s+"/, "\"")		#removes spaces between value and "
		hash = hash.gsub(/"\s+/, "\"")		#removes spaces between " and value
		return hash
	end

	### 	The data for an update is encapsuled in double-quotes so
	### 	the double-quotes inside the data need to be escaped.
	def self.add_escapes(hash)
		hash = hash.gsub("\"", "\\\"")
		return hash
	end

	### 	Jira doesn't accept 'null' for option-types and adds 
	### 	0.0 for empty number-types. Removing all 'empty' keys
	### 	is the safest way to ensure a successful POST or PUT
	### 	request.
	def self.delete_blanks(hash)
		hash["fields"].each do |key, value|
			next if key == "assignee"
			hash["fields"].delete(key) if value == nil || value == 0.0
			if value.respond_to?(:key?) #if true, means customfield has nested hash
				value.each do |k, v|
					#empty option types usually don't have a nested hash
					#so this if statement might not be needed
					hash["fields"].delete(key) if v == nil || v == 0.0
				end
			end
		end
	return hash
	end

end

module CompareHashes

	### 	Translates the key from new_hash to the matching customfield_id
	def self.getID(key)
		case key
			when "OS" 							then return "customfield_11018"
			when "OS Version"					then return "customfield_11019"
			when "CPU Model"					then return "customfield_11022"
			when "CPU Speed"					then return "customfield_11023"
			when "RAM"							then return "customfield_11024"
			when "RAM Speed"					then return "customfield_11026"
			when "RAM Speed | Type"				then return "customfield_11026"
			when "RAM Upgradeable"				then return "customfield_11025"
			when "CPU Cores"					then return "customfield_11027"
			when "Internal Storage Capacity" 	then return "customfield_11029"
			when "USB Type"						then return "customfield_11037"
			when "Number of Thunderbolt Ports" 	then return "customfield_11038"
			when "Thunderbolt Type" 			then return "customfield_11040"
			when "Power Supply (Energy)"		then return "customfield_11042"
			when "Firewire Ports"				then return "customfield_11044"
			when "MAC Address (WIFI)"			then return "customfield_11054"
			when "MAC Address (Ethernet)"		then return "customfield_11055"
			when "MAC Address (Bluetooth)"		then return "customfield_11056"
			when "Graphics Card 1"				then return "customfield_11057"
			when "Graphics Card 2"				then return "customfield_11058"
			when "VRAM"							then return "customfield_11059"
			when "Battery Capacity"				then return "customfield_11061"
			when "Bluetooth Version"			then return "customfield_11100"			
			when "SDK Version"					then return "customfield_11105"
			when "Product Type"					then return "customfield_11107"
			when "UDID"							then return "customfield_11200"
			when "Touch ID"						then return "customfield_11210"
			#when "Device Name"					then return "summary"
			#when "IssueType"					then return "description"
			#when "Project Name"				then return "project"
			when "Manufacturing Year"			then return "customfield_11203"
			when "SoC"							then return "customfield_11204"
			when "CPU Arch"						then return "customfield_11205"
			when "GPU"							then return "customfield_11206"
			when "GPU Cores"					then return "customfield_11207"
			when "GPU Speed"					then return "customfield_11212"
			when "DPI"							then return "customfield_11208"
			when "Display Size"					then return "customfield_11021"
			when "Motion Sensor"				then return "customfield_11209"
			when "Front Camera"					then return "customfield_11103"
			when "Rear Camera"					then return "customfield_11104"
			when "manufacturer"					then return "customfield_11003"
			when "Color"						then return "customfield_11106"
			when "Product Type"					then return "customfield_11107"
			when "Display Resolution"			then return "customfield_11060"
			when "Model"						then return "customfield_11004"
			when "Serial Number"				then return "customfield_11002"
			when "UDID"							then return "customfield_11200"
			when "IMEI"							then return "customfield_11201"
			when "SDK Version"					then return "customfield_11105"
			when "Asset Number"					then return "customfield_11009"
			when "Purchase Date"				then return "customfield_11005"
			when "Purchase Cost"				then return "customfield_11006"
			when "Supplier"						then return "customfield_11010"
			when "Order Number"					then return "customfield_11008"
			else return false
		end
	end

	### 	Translates the key from new_hash to the matching customfield_type
	def self.getType(key)
		case key
			#when "assignee"						then return "String" #type is "user" but functions like String(?)
			when "OS" 							then return "Option"
			when "OS Version"					then return "String"
			when "CPU Model"					then return "String"
			when "CPU Speed"					then return "Number"
			when "RAM"							then return "String"
			when "CPU Cores"					then return "Number"
			when "Internal Storage Capacity" 	then return "Number"
			when "USB Type"						then return "Option"
			when "Number of Thunderbolt Ports" 	then return "Number"
			when "Thunderbolt Type" 			then return "Option"
			when "Power Supply (Energy)"		then return "Number"
			when "Firewire Ports"				then return "String"
			when "Graphics Card 1"				then return "String"
			when "Graphics Card 2"				then return "String"
			when "VRAM"							then return "Number"
			when "Battery Capacity"				then return "Number"
			when "Bluetooth Version"			then return "Number"
			when "SDK Version"					then return "String"
			when "Touch ID"						then return "String"
			#when "summary"						then return "String"
			#when "IssueType"					then return "Nested" #"name" instead of "value"
			when "Manufacturing Year"			then return "Number"
			when "SoC"							then return "String"
			when "RAM Speed | Type"				then return "String"
			when "RAM Speed"					then return "String"
			when "RAM Upgradeable"				then return "Option"
			when "CPU Arch"						then return "String"
			when "GPU"							then return "String"
			when "GPU Cores"					then return "Number"
			when "GPU Speed"					then return "Number"
			when "DPI"							then return "Number"
			when "Display Size"					then return "Number"
			when "Motion Sensor"				then return "String"
			when "Front Camera"					then return "String"
			when "Rear Camera"					then return "String"
			when "manufacturer"					then return "Option"
			when "Color"						then return "String"
			when "Product Type"					then return "String"
			when "Display Resolution"			then return "String"
			when "MAC Address (Bluetooth)"		then return "String"
			when "MAC Address (Ethernet)"		then return "String"
			when "MAC Address (WIFI)"			then return "String"
			when "Model"						then return "String"
			when "Serial Number"				then return "String"
			when "UDID"							then return "String"
			when "IMEI"							then return "String"
			when "SDK Version"					then return "String"
			when "Asset Number"					then return "String"
			when "Purchase Date"				then return "Date"
			when "Purchase Cost"				then return "Number"
			when "Supplier"						then return "String"
			when "Order Number"					then return "String"
			#when "Project Name"				then return "Nested"						
			else return false
		end
	end


	### 	Compares a hash (asset_hash), created from new hardware data
	### 	to the latest Jira Issue (jira_hash). If the values of
	### 	a key aren't equal, the new value (from asset_hash) gets 
	### 	stored in a new hash (update_hash) and is later pushed to 
	### 	Jira as an update.
	def self.compare_hashes(asset_hash, jira_hash)
		update_hash = {}
		update_hash.store("fields", {})
		
		#Thunderbolt Type sometimes gets saved with trailing space, which leads
		#to an error when trying to update
		if asset_hash.has_key?("Thunderbolt Type") && asset_hash["Thunderbolt Type"] != nil
			asset_hash["Thunderbolt Type"] = asset_hash["Thunderbolt Type"].rstrip
		end

		asset_hash.each do |key, value|
			_ID = getID(key)
			next if _ID == false #some values can't change (eg MAC Address) and
				#are not included in the getID function

			#Empty option types don't have a nested hash, so 'null-check' needs different
			#comparison
			if getType(key) == "Option"
				if jira_hash["fields"][_ID] == nil && value != nil
					update_hash["fields"].store(_ID, {})
					update_hash["fields"][_ID].store("value", value)
				elsif jira_hash["fields"][_ID].respond_to?(:key?)
					if value != jira_hash["fields"][_ID]["value"]
						update_hash["fields"].store(_ID, {})
						update_hash["fields"][_ID].store("value", value)
					end
				else
					next
				end
			else				
				value = value.to_f if jira_hash["fields"][_ID].is_a?(Float) || getType(key) == "Number"
				if value != jira_hash["fields"][_ID]
					update_hash["fields"].store(_ID, value)
				end				
			end
		end
		#update_hash gets initialized as {"fields => {}"} at the beginning
		#of the function. Returning nil in case no value is stored adds
		#some safety.		

		return nil if update_hash["fields"].empty?		
		return update_hash
	end 	# can't get type of empty cells. updating null-values that are supposed to be
			# numbers (or options?) not yet possible!

	
		
	
end

module CreateHash

	def self.create_ios_header(csv_hash)
		new_hash = {}
		new_hash.store("fields", {})
		new_hash["fields"].store("assignee", nil)
		new_hash["fields"].store("project", {})
		new_hash["fields"]["project"].store("key", csv_hash["Project Name"])
		new_hash["fields"].store("summary", csv_hash["Device Name"])
		new_hash["fields"].store("issuetype", {})
		new_hash["fields"]["issuetype"].store("name", csv_hash["IssueType"])
		return new_hash
	end

	def self.create_osx_header(csv_hash)
		new_hash = {}
		new_hash.store("fields", {})
		new_hash["fields"].store("assignee", nil)
		new_hash["fields"].store("project", {})
		new_hash["fields"]["project"].store("key", csv_hash["Project Name"])
		new_hash["fields"].store("summary", csv_hash["Model"])
		new_hash["fields"].store("issuetype", {})
		new_hash["fields"]["issuetype"].store("name", csv_hash["IssueType"])
		return new_hash
	end

	def self.create_default_post_header()
		new_hash = {}
		new_hash.store("fields", {})
		return new_hash
	end

	def self.create_post_hash(csv_hash, new_hash)
		if new_hash == nil
			new_hash = create_default_post_header()
		end

		csv_hash.each do |key, value|
			_ID = CompareHashes.getID(key)
			next if _ID == false
			_type = CompareHashes.getType(key)
			next if _type == false

			if _type == "Option"
				new_hash["fields"].store(_ID, {})
				new_hash["fields"][_ID].store("value", value)
			else
				value = value.to_f if _type == "Number"
				new_hash["fields"].store(_ID, value)
			end
		end
		return new_hash
	end

	def self.create_link_hash(key, serial, imei)
		hash = {
			"key" => key,
			"serial" => serial,
			"imei" => imei
		}
		return hash
	end

	def self.create_hash_file(file_name, hash)
		hash_file = File.open(file_name, "w")
		hash_file.write(hash)
		hash_file.close
	end

	def self.read_hash_file(file_name)
		hash_file = File.read(file_name)
		hash = JSON.parse(hash_file)
		return hash
	end
end

