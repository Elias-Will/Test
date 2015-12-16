require 'csv'
require 'json'

# 	Matches Jira Query to Inventory
# 	using Serial Number/IMEI
#
# 	Saves to new <key>.json, including 
# 	Inventory Name and Issue Key
#
# 	Serial Number (IMEI for PH) is the
# 	only unique identifier. If it's nil,
# 	a match cannot be made

directory_issue = "AM/AM-*.json" #Jira Issue
#directory_hash = "JSON_serial/*.json"
directory_hash = "testmatch/t_json/*_match.json"
log_file = File.open("update_log.txt", "a")
log_count = 0 #for testing
p_count = 0 # ...
t_count = 0 # ...


#Gets latest Jira Issues
#puts `for i in {1..299}; do curl -u elias.will:Kappa-123- https://kupferwerk.atlassian.net/rest/api/latest/issue/AM-$i?expand=renderedFields | python -m json.tool > ~/Documents/Jira/AM/AM-$i.json; done`
#puts `curl -u elias.will:Kappa-123- https://kupferwerk.atlassian.net/rest/api/latest/issue/AM-25?expand=renderedFields |python -m json.tool > ~/Documents/Jira/AM/AM-25.json`


def updateLog(isMatch, issue_key, log_file, current_time)
	if !isMatch
		log = "Jira Issue #{issue_key} has no matching entry in local Inventory or was already updated"
		puts log
		log_file.write(current_time.inspect + ": " + log + "\n")
	end
end

def curlSingleIssue(user_id, key)
	puts `curl -u #{user_id} https://kupferwerk.atlassian.net/rest/api/latest/issue/#{key}?expand=renderedFields |python -m json.tool > ~/Documents/Jira/AM/#{key}.json`

end

#def isUpdated(asset_number)
#end



# 	opens Jira Query File
Dir[directory_issue].each do |issue|
	#-----------------
	match = false
	time = Time.now #for Logfile
	issue_file = File.read(issue)
	issue_data = JSON.parse(issue_file)
	#-----------------

	#to exclude 'empty' AM-* files
	next if issue_data.include?("errorMessages") 
	key = issue_data["key"] #if file exists, get the Key
	#if Jira Issue is already up-to-date, don't update again
	if issue_data["fields"]["customfield_11009"] != nil
		updateLog(false, key, log_file, time)
		next
	end
	
	#type used to determine which number (Serial/IMEI) to use for matching [ERROR: Not all TA's use SN]
	type = (issue_data["fields"]["customfield_11201"] == nil) ? "SN" : "IMEI"

	# 	variables used for curl GET/SET commands
	bash_user = "elias.will:Kappa123k"
	bash_contenttype = "Content-Type: application/json"
	bash_url = "https://kupferwerk.atlassian.net/rest/api/latest/issue/#{key}"
	# 	------------------------------------

	# 	opens Inventory Hash containing Serial/IMEI & Inventory Number
	Dir[directory_hash].each do |f|
		hash_file = File.read(f)
		hash_data = JSON.parse(hash_file)

		# 	compares Serial/IMEI of Inventory to Jira Query		
		# 	Case: Type = IMEI => asset is a phone; uses IMEI to find matching inventory
		if (type == "IMEI" && hash_data["customfield_11201"] == issue_data["fields"]["customfield_11201"] &&
			hash_data["customfield_11201"] != nil)
			match = true

			#------gets latest version of issue
			curlSingleIssue(bash_user, key)
			issue_file = File.read(issue)
			issue_data = JSON.parse(issue_file)
			if issue_data["fields"]["customfield_11009"] != nil
				updateLog(false, key, log_file, time)
				break
			end
			#-----

			inventory = hash_data["customfield_11009"]		
			req_file = "testmatch/t_json/" + inventory + "_curl.json"
			req_file = File.read(req_file).to_s

			# 	creates BASH command to update matching Jira Issue			
			#bash_issue_add = "curl -D- -u #{bash_user} -X PUT --data '#{req_file}' -H #{bash_contenttype} #{bash_url}"			
			puts `curl -D- -u #{bash_user} -X PUT --data '#{req_file}' -H \"#{bash_contenttype}\" #{bash_url}`
			
			p_count += 1
			log = "Jira Issue #{key} was updated using data from Inventory #{inventory}"			
			log_file.write(time.inspect + ": " + log + " #{p_count}" + "\n")
			log_file.write("IMEI  : " + issue_data["fields"]["customfield_11201"] + "\n")
			log_file.write("\t" + req_file + "\n\n")

		# 	Case: Type = SN => asset is NOT a phone; uses Serial Number to find matching inventory
		elsif (type == "SN" && hash_data["customfield_11002"] == issue_data["fields"]["customfield_11002"] &&
			hash_data["customfield_11002"] != nil)
			match = true

			#------gets latest version of issue
			curlSingleIssue(bash_user, key)
			issue_file = File.read(issue)
			issue_data = JSON.parse(issue_file)
			if issue_data["fields"]["customfield_11009"] != nil
				updateLog(false, key, log_file, time)
				break
			end
			#-----



			inventory = hash_data["customfield_11009"]
			req_file = "testmatch/t_json/" + inventory + "_curl.json"
			req_file = File.read(req_file).to_s	
			

			#bash_issue_add = "curl -D- -u #{bash_user} -X PUT --data '#{req_file}' -H #{bash_contenttype} #{bash_url}"
			puts `curl -D- -u #{bash_user} -X PUT --data '#{req_file}' -H \"#{bash_contenttype}\" #{bash_url}`
			
			log_count += 1
			if req_file.include?("TA")
				t_count += 1
			end
			log = "Jira Issue #{key} was updated using data from Inventory #{inventory}"
			log_file.write(time.inspect + ": " + log + " #{log_count}" + "\n")
			log_file.write("Serial: " + issue_data["fields"]["customfield_11002"] + "\n")
			log_file.write("\t" + req_file + "\n\n")		
		end
		break if match == true #stops loop through local inventory; saves time
	end
	if match == false
		updateLog(false, key, log_file, time)		
	end
end
log_file.write("\nPH: " + p_count.to_s + "\nTA: " + t_count.to_s)
log_file.close



			#bash_inventory_data = `cat #{req_file} | tr -d '[[:space:]]'`

			#for i in {1..299}; do curl -u elias.will:Kappa-123- https://kupferwerk.atlassian.net/rest/api/latest/issue/AM-$i?expand=renderedFields | python -m json.tool > ~/Documents/Jira/AM/AM-$i.json; done
=begin

at start of script:
prompt user to enter username, password, new inventory file

create csv from xlsx
create json for matching and curl
search for issue locally
	possibly update local issues with curl get
check if issue needs update
update
download updated issue


=end

