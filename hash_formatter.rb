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
			when "CPU Cores"					then return "customfield_11027"
			when "Internal Storage Capacity" 	then return "customfield_11029"
			when "USB Type"						then return "customfield_11037"
			when "Number of Thunderbolt Ports" 	then return "customfield_11038"
			when "Thunderbolt Type" 			then return "customfield_11040"
			when "Power Supply (Energy)"		then return "customfield_11042"
			when "Firewire Ports"				then return "customfield_11044"
			when "MAC Address (WIFI)"			then return "customfield_11054"
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
			else return false
		end
	end

	### 	Translates the key from new_hash to the matching customfield_type
	def self.getType(key)
		case key
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
			else return false
		end
	end


	### 	Compares a hash (new_hash), created from new hardware data
	### 	to the latest Jira Issue (current_hash). If the values of
	### 	a key aren't equal, the new value (from new_hash) gets 
	### 	stored in a new hash (update_hash) and is later pushed to 
	### 	Jira as an update.
	def self.compare_hashes(new_hash, current_hash)
		update_hash = {}
		update_hash.store("fields", {})

		new_hash.each do |key, value|
			_ID = getID(key)
			next if _ID == false #some values can't change (eg MAC Address) and
				#are not included in the getID function

			if current_hash["fields"][_ID].respond_to?(:key?) || getType(key) == "Option" #if true, means
												#the current field is an option-type with a nested hash
				if value != current_hash["fields"][_ID]["value"]
					update_hash["fields"].store(_ID, {})
					update_hash["fields"][_ID].store("value", value)
				end
			else				
				value = value.to_f if current_hash["fields"][_ID].is_a?(Float) || getType(key) == "Number"
				if value != current_hash["fields"][_ID]
					update_hash["fields"].store(_ID, value)
				end				
			end
		end
		#update_hash gets initialized as {"fields => {}"} at the beginning
		#of the function. Returning nil in case no value is stored adds
		#some safety.
		return nil if update_hash["fields"].empty?
		update_hash["fields"].store("assignee", nil)
		return update_hash
	end 	# can't get type of empty cells. updating null-values that are supposed to be
			# numbers (or options?) not yet possible!
end








=begin
	def self.compare_hashes(old_hash, new_hash)
		update_hash = {}
		update_hash.store("fields", {})
		old_hash["fields"].each do |key, value|
			skip = false
			if value.respond_to?(:key?)
				value.each do |k, v|				
					_k = getKeyName(key)
					next if _k == false
					new_hash[_k] = new_hash[_k].to_f if v.is_a?(Float)
					if v != new_hash[_k]
						update_hash["fields"].store(key, {})
						update_hash["fields"][key].store("value", new_hash[_k])
					end					
					skip = true
				end
			end
			next if skip		
			_k = getKeyName(key)
			next if _k == false
			new_hash[_k] = new_hash[_k].to_f if value.is_a?(Float)
			if value != new_hash[_k]
				update_hash["fields"].store(key, new_hash[_k])
			end
		end
		return nil if update_hash["fields"].empty?
		return update_hash
	end

	def self.getKeyName(key)
		case key
			when "customfield_11018" then return "OS"
			when "customfield_11027" then return "CPU Cores"
			when "customfield_11022" then return "CPU Model"
			when "customfield_11023" then return "CPU Speed"
			when "customfield_11029" then return "Internal Storage Capacity"
			when "customfield_11019" then return "OS Version"
			when "customfield_11024" then return "RAM"
			when "customfield_11044" then return "Firewire Ports"
			when "customfield_11057" then return "Graphics Card 1"
			when "customfield_11058" then return "Graphics Card 2"
			when "customfield_11038" then return "Number of Thunderbolt Ports"
			when "customfield_11040" then return "Thunderbolt Type"
			when "customfield_11037" then return "USB Type"
			when "customfield_11059" then return "VRAM"
			when "customfield_11042" then return "Power Supply (Energy)"
			when "customfield_11061" then return "Battery Capacity"
			when "customfield_11100" then return "Bluetooth Version"
			when "customfield_11210" then return "Touch ID"
			when "customfield_11105" then return "SDK Version"
			else return false
		end
	end
=end