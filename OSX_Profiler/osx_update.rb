require 'json'
require 'optparse'

$user = nil
op = OptionParser.new do |opts|
	opts.on('-u', '--user user', 'User') { |user| $user = user }
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def getUser()
	puts "Enter username:password"
	print "> "
	$user = $stdin.gets.chomp
	return $user
end

def curlSingleIssue(key)
	puts `curl -u #{$user} https://kupferwerk.atlassian.net/rest/api/latest/issue/#{key}?expand=renderedFields | python -m json.tool > ./current_issue.json`
end

def curlUpdateIssue(key, data)
	puts `curl -D- -u #{$user} -X PUT --data "#{data}" -H "Content-Type: application/json" https://kupferwerk.atlassian.net/rest/api/latest/issue/#{key} > update_log.txt`
end

$user = getUser() unless $user != nil
files = "*update.json"
Dir[files].each do |f|
	puts f
	_file = File.read(f)
	jira_location_hash = JSON.parse(_file)
	hash_file = Dir.glob("*hash.json").first
	_file = File.read(hash_file)
	new_hash = JSON.parse(_file)

	key = jira_location_hash["key"]
	curlSingleIssue(key)

	curl_file = File.read("current_issue.json")
	current_hash = JSON.parse(curl_file)

	update_hash = { "fields" => {
		#"customfield_11018" => {
		#	"value" => new_hash["OS"]
		#	},
		"customfield_11027" => new_hash["CPU Cores"].to_f,
		"customfield_11022" => new_hash["CPU Model"],
		"customfield_11023" => new_hash["CPU Speed"].to_f,
		"customfield_11029" => new_hash["Internal Storage Capacity"].to_f,
		"customfield_11019" => new_hash["OS Version"],
		"customfield_11024" => new_hash["RAM"],###
		"customfield_11044" => new_hash["Firewire Ports"].to_f,
		"customfield_11057" => new_hash["Graphics Card 1"],
		"customfield_11058" => new_hash["Graphics Card 2"],
		"customfield_11038" => new_hash["Number of Thunderbolt Ports"].to_f,
		"customfield_11042" => new_hash["Power Supply (Energy)"].to_f,
		#"customfield_11040" => {
		#	"value" => new_hash["Thunderbolt Type"]
		#},
		#"customfield_11037" => {
		#	"value" => new_hash["USB Type"]
		#},
		"customfield_11059" => new_hash["VRAM"].to_f
		} 
	}	
	
	#if new_hash["OS"] == current_hash["fields"]["customfield_11018"]["value"]
	#	update_hash["fields"].delete("customfield_11018")
	#end
	if new_hash["CPU Cores"] == current_hash["fields"]["customfield_11027"] || update_hash["fields"]["customfield_11027"] == 0.0
		update_hash["fields"].delete("customfield_11027")
	end
	if new_hash["CPU Model"] == current_hash["fields"]["customfield_11022"]
		update_hash["fields"].delete("customfield_11022")
	end
	if new_hash["CPU Speed"] == current_hash["fields"]["customfield_11023"] || update_hash["fields"]["customfield_11023"] == 0.0
		update_hash["fields"].delete("customfield_11023")
	end
	if new_hash["Internal Storage Capacity"] == current_hash["fields"]["customfield_11029"] || update_hash["fields"]["customfield_11029"] == 0.0
		update_hash["fields"].delete("customfield_11029")
	end
	if new_hash["OS Version"] == current_hash["fields"]["customfield_11019"]
		update_hash["fields"].delete("customfield_11019")
	end
	if new_hash["RAM"] == current_hash["fields"]["customfield_11024"]
		update_hash["fields"].delete("customfield_11024")
	end
	if new_hash["Firewire Ports"] == current_hash["fields"]["customfield_11044"] || update_hash["fields"]["customfield_11044"] == 0.0
		update_hash["fields"].delete("customfield_11044")
	end
	if new_hash["Graphics Card 1"] == current_hash["fields"]["customfield_11057"]
		update_hash["fields"].delete("customfield_11057")
	end
	if new_hash["Graphics Card 2"] == current_hash["fields"]["customfield_11058"]
		update_hash["fields"].delete("customfield_11058")
	end
	if new_hash["Number of Thunderbolt Ports"] == current_hash["fields"]["customfield_11038"] || update_hash["fields"]["customfield_11038"] == 0.0
		update_hash["fields"].delete("customfield_11038")
	end
	if new_hash["Power Supply (Energy)"] == current_hash["fields"]["customfield_11042"] || update_hash["fields"]["customfield_11042"] == 0.0
		update_hash["fields"].delete("customfield_11042")
	end
	#if new_hash["Thunderbolt Type"] == current_hash["fields"]["customfield_11040"]["value"]
	#	update_hash["fields"].delete("customfield_11040")
	#end
	#if new_hash["USB Type"] == current_hash["fields"]["customfield_11037"]["value"]
	#	update_hash["fields"].delete("customfield_11037")
	#end
	if new_hash["VRAM"] == current_hash["fields"]["customfield_11059"] || update_hash["fields"]["customfield_11059"] == 0.0
		update_hash["fields"].delete("customfield_11059")
	end
	

	update_hash = JSON.pretty_generate(update_hash)		
	update_hash = update_hash.gsub(/\n/, "")
	update_hash = update_hash.gsub(/:\s+/, ":")
	update_hash = update_hash.gsub(/\{\s+/, "{")
	update_hash = update_hash.gsub(/\s+}/, "}")
	update_hash = update_hash.gsub(/,\s+/, ",")
	update_hash = update_hash.gsub("\"", "\\\"")
	curlUpdateIssue(key, update_hash)
end

=begin
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
				#Firewire Ports
				#Graphics Card 1
				#Graphics Card 2
				"customfield_11029" => csv_hash["Internal Storage Capacity"].to_f,
				"customfield_11056" => csv_hash["MAC Address (Bluetooth)"],
				#MAC Address (Ethernet)
				"customfield_11054" => csv_hash["MAC Address (WiFi)"],
				"customfield_11004" => csv_hash["Model"],
				#Number of Thunderbolt Ports
				"customfield_11019" => csv_hash["OS Version"],
				#Power Suppy (Energy)
				"customfield_11024" => csv_hash["RAM"],
				#RAM Speed
				#RAM Upgradeable
				"customfield_11002" => csv_hash["Serial Number"]
				#Thunderbolt Type
				#USB Type
				#VRAM
			}
	




=end