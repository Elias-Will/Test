require 'csv'
require 'json'
require 'optparse'
require 'logger'


def getUser()
	puts "Enter username:password"
	print "> "
	user = $stdin.gets.chomp
	return user
end

def defaultURL()
	def_protocol = "https://"
	def_host = "kupferwerk.atlassian.net"
	def_file = "/rest/api/latest"
	def_mode = "/issue/"
	return def_protocol + def_host + def_file + def_mode
end

def getJiraKey()
	puts "Enter Key"
	print "> "
	key = $stdin.gets.chomp
	return key
	#needs option to read from file
end

### --- Searching for matching Jira Issue --- ###
def curlSearch_Header()
	puts `curl -D- -u #{$user} #{$url}#{$jira_key}?expand=renderedFields > #{$jql_header}`
end

def curlSearch()
	puts `curl -u #{$user} #{$url}#{$jira_key}?expand=renderedFields \
	| python -m json.tool > #{$jql_response}`
end

def curlUpdate(data)
	#puts `curl -D- -u #{$user} -X PUT --data "#{data}" -H \
	#{}"Content-Type: application/json" #{$url}#{$jira_key} > #{$update_response}`
end

def checkHeader()
	header_file = File.read($jql_header)
	if header_file.include?("HTTP/1.1 200 OK")
		return true
	else
		puts header_file.slice(0..25)
		return false
	end
end

def checkMatch()
	response_file = File.read($jql_response)
	data = JSON.parse(response_file)

	if data["total"] == 0
		Kernel.abort("###No matching issue was found!###")
	elsif data["total"] == 1
		return true
	else
		Kernel.abort("Duplicate!")
	end
end
### ----------------------------------------- ###
###
def searchLocalAsset()
	_f = File.read($jql_response)
	_d = JSON.parse(_f)
	serial = _d["fields"]["customfield_11002"]
	#imei = _d["fields"]["customfield_11201"]
	directory = "~/Documents/Jira/update_jira_from_excel/*_match.json"
	Dir[directory].each do |f|
		puts f
		file = File.read(f)
		data = JSON.parse(file)
		if data["customfield_11002"] == serial
			$asset = data["customfield_11002"]
			puts $asset, data["customfield_11002"]
		else
			next
		end
	end
end

def updateIssue()
	if $asset
		file = File.read($asset + "_curl.json")
		data = JSON.parse(file)
		puts "MATCH"
		#curlUpdate(data)
	end
end

$log = Logger.new 'log.txt'
op = OptionParser.new do |opts|
	#opts.banner = ''
	#opts.on('-a', '--all', 'Search Issue for all files') { $parse_all = true }
	opts.on('-k', '--key key', 'Jira Issue Key') { |key| $jira_key = key }
	opts.on('-P', '--project P', 'Project Name') { |p| $jira_project = p }
	opts.on('-u', '--user u', 'Username & Password') { |u| $user = u }
	opts.on('', '--url url', 'Use different URL') { |url| $url = url }
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

$jql_header = "jql_header.txt"
$jql_response = "jql_response.json"
$update_response = "update_log.txt"

$user = nil
$url = defaultURL()
$jira_project = nil
$jira_key = nil
$asset = nil

def main()
	$user = getUser() unless $user != nil
	$jira_key = getJiraKey() unless $jira_key != nil
	curlSearch_Header()
	checkHeader()
	curlSearch()
	#checkMatch()
	searchLocalAsset()
	updateIssue()
end

=begin
	
curl -D- -u admin:admin -X POST -H "Content-Type: application/json" --data 
'{"jql":"project = QA","startAt":0,"maxResults":2,"fields":["id","key"]}' 
"http://kelpie9:8081/rest/api/2/search"

=end

main()