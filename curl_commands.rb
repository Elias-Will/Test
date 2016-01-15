module GlobalVariables
	### Global variables, which are also used in the scrips
	### including this module.
	$output_file_h = "HTTP_header.txt"
	$output_file_search  = "search_result.json"
	$output_file_create = "create_log.txt"
	$output_file_issue = "current_issue.json"
	$output_file_update = "update_log.txt"
	$output_file_jql = "jql_multiple_issues.json"
	$def_protocol = "https"
	$def_host = "kupferwerk.atlassian.net"
	$def_api = "rest/api/latest/"
	$def_address = $def_protocol + "://" + $def_host + "/" + $def_api 
	#$address = "https://kupferwerk.atlassian.net/rest/api/latest/"
	$search_address = $def_address + "search"
	$create_address = $def_address + "issue"
	##########
end

module CurlCommand
	# 	Returns the search result including the HTTP header, which
	# 	includes the response of the curl request. The program 
	# 	only continues if the response is "HTTP/1.1 200 OK"
	def self.curl_search_header(user, jira_project, mode, value)
		puts `curl -D- -u #{user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = #{jira_project} AND \\\"#{mode}\\\" ~ #{value}","fields":["key"]}' \
			\"#{$search_address}\" > #{$output_file_h}`
	end

	# 	Same as above, only without the HTTP header. Needed to parse
	# 	the Jira response for a hash (HTTP header makes it impossible)
	def self.curl_search(user, jira_project, mode, value)
		puts `curl -u #{user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = #{jira_project} AND \\\"#{mode}\\\" ~ #{value}","fields":["key"]}' \
			\"#{$search_address}\" | python -m json.tool > #{$output_file_search}`
	end

	# 	Creates a completely new issue in Jira with the given data.
	# 	The data also includes the project key.
	def self.curl_create_issue(user, data)
		puts `curl -D- -u #{user} -X POST --data '#{data}' -H \
			"Content-Type: application/json" #{$create_address} > #{$output_file_create}`
	end

	# 	Gets the data from the Jira issue with the given key.
	def self.curl_single_issue(user, key)
		puts `curl -u #{user} #{$create_address}/#{key}?expand=renderedFields \
		| python -m json.tool > #{$output_file_issue}`
	end

	# 	Same as above, however option for custom file names (eg when used in loop)
	def self.curl_single_issue_jql(user, key, output_file_name)
		puts `curl -u #{user} #{$create_address}/#{key}?expand=renderedFields \
		| python -m json.tool > #{output_file_name}`
	end

	# 	Updates an existing Jira issue. It's very important that the 'data'
	# 	variable has no incompatible values (ie string for number-cell) or 
	# 	characters (ie spaces, new lines).
	def self.curl_update_issue(user, data, key)
		puts `curl -D- -u #{user} -X PUT --data "#{data}" -H \
		"Content-Type: application/json" #{$create_address}/#{key} \
		> #{$output_file_update}`
	end

	# 	Returns Jira Key(s) of multiple issues matching the given conditions (eg Asset Numer is EMPTY)
	# 	Seems to return a maximum of 50 results.
	# 	'jql_conditions' has to start with AND/OR/ORDER BY
	def self.curl_multiple_issues_jql(user, jira_project, jql_conditions)
		puts `curl -u #{user} -X POST -H "Content-Type: application/json" --data \
		'{"jql":"project = #{jira_project} #{jql_conditions}","fields":["key"]}' #{$search_address} \
		| python -m json.tool > #{$output_file_jql}`
	end
end

module CurlResponse
	def self.check_search_result_header(file_name)
		search_result_header = File.read(file_name)
		if search_result_header.include?("HTTP/1.1 200 OK")
			return true
		#no proper case-handling possible when using osx_wrapper
		elsif search_result_header.include?("HTTP/1.1 401 Unauthorized")
			#future case-handling
		elsif search_result_header.include?("HTTP/1.1 502 Bad Gateway")
			#future case-handling
		else
			#different HTTP-Errors
		end
		return false
	end

	def self.check_search_result(file_name)
		search_result_data = CreateHash.read_hash_file(file_name)
		return false if search_result_data.include?("errorMessages")
		if search_result_data["total"] == 0
			return false
		elsif search_result_data["total"] == 1
			return true
		elsif search_result_data["total"] > 1
			#for future case-handling
			return search_result_data["total"]
		end
	end
end
