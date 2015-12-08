require 'json'

def getUser()
	puts "Enter username:password"
	print "> "
	user = $stdin.gets.chomp
	return user
end

def curlCreateIssue(user, data)
	#puts `curl -D- -u #{user} -X POST --data #{data} -H \
	#		"Content-Type: application/json" https://kupferwerk.atlassian.net/rest/api/latest/issue/`
end


user 

files = "*_create.json"
user = getUser() unless user != nil
Dir[files].each do |f|
	create_hash = File.read(f)
	puts create_hash, user	
	curlCreateIssue(user, create_hash)
end