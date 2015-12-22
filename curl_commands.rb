module CurlCommands

	### Global variables, which are also used in the scrips
	### including this module.
	$output_file_h = "HTTP_header.txt"
	$output_file_search  = "search_result.json"
	$output_file_create = "create_log.txt"
	$output_file_issue = "current_issue.json"
	$output_file_update = "update_log.txt"
	$address = "https://kupferwerk.atlassian.net/rest/api/latest/"
	$search_address = $address + "search"
	$create_address = $address + "issue"
	##########

	# 	Returns the search result including the HTTP header, which
	# 	includes the response of the curl request. The program 
	# 	only continues if the response is "HTTP/1.1 200 OK"
	def self.curlSearch_Header(user, jira_project, mode, value)
		puts `curl -D- -u #{user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = #{jira_project} AND \\\"#{mode}\\\" ~ #{value}","fields":["key"]}' \
			\"#{$search_address}\" > #{$output_file_h}`
	end

	# 	Same as above, only without the HTTP header. Needed to parse
	# 	the Jira response for a hash (HTTP header makes it impossible)
	def self.curlSearch(user, jira_project, mode, value)
		puts `curl -u #{user} -X POST -H "Content-Type: application/json" --data \
			'{"jql":"project = #{jira_project} AND \\\"#{mode}\\\" ~ #{value}","fields":["key"]}' \
			\"#{$search_address}\" | python -m json.tool > #{$output_file_search}`
	end

	# 	Creates a completely new issue in Jira with the given data.
	# 	The data also includes the project key.
	def self.curlCreateIssue(user, data)
		puts `curl -D- -u #{user} -X POST --data '#{data}' -H \
			"Content-Type: application/json" #{$create_address} > #{$output_file_create}`
	end

	# 	Gets the data from the Jira issue with the given key.
	def self.curlSingleIssue(user, key)
		puts `curl -u #{user} #{$create_address}/#{key}?expand=renderedFields | python -m json.tool > #{$output_file_issue}`
	end

	# 	Updates an existing Jira issue. It's very important that the 'data'
	# 	variable has no incompatible values (ie string for number-cell) or 
	# 	characters (ie spaces, new lines).
	def self.curlUpdateIssue(user, data, key)
		puts `curl -D- -u #{user} -X PUT --data "#{data}" -H "Content-Type: application/json" #{$create_address}/#{key} > #{$output_file_update}`
	end
end