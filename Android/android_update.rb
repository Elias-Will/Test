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
	puts `curl -D- -u #{$user} -X PUT --data "#{data}" -H "Content-Type: application/json" https://kupferwerk.atlassian.net/rest/api/latest/issue/#{key}`
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
		"customfield_11018" => {
			"value" => new_hash["OS"]
			},
		"customfield_11029" => new_hash["Internal Storage Capacity"].to_f,
		"customfield_11019" => new_hash["OS Version"],
		"customfield_11061" => new_hash["Battery Capacity"].to_f,
		"customfield_11100" => new_hash["Bluetooth Version"].to_f,
		"customfield_11105" => new_hash["SDK Version"]
		}
	}	
	
	if new_hash["OS"] == current_hash["fields"]["customfield_11018"]["value"]
		update_hash["fields"].delete("customfield_11018")
	end
	if new_hash["Internal Storage Capacity"] == current_hash["fields"]["customfield_11029"] || update_hash["fields"]["customfield_11029"] == 0.0
		update_hash["fields"].delete("customfield_11029")
	end
	if new_hash["OS Version"] == current_hash["fields"]["customfield_11019"]
		update_hash["fields"].delete("customfield_11019")
	end
	if new_hash["Battery Capacity"] == current_hash["fields"]["customfield_11061"] || update_hash["fields"]["customfield_11061"] == 0.0
		update_hash["fields"].delete("customfield_11061")
	end
	if new_hash["Bluetooth Version"] == current_hash["fields"]["customfield_11100"] || update_hash["fields"]["customfield_11100"] == 0.0
		update_hash["fields"].delete("customfield_11100")
	end
	if new_hash["SDK Version"] == current_hash["fields"]["customfield_11105"]
		update_hash["fields"].delete("customfield_11105")
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