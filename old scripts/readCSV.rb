require 'csv'
require 'json'

# 	Takes csv and saves content as hash in
# 	#_IssueType_hash.json.
# 	Calls 'searchJira.rb' at the end, which
# 	searches Jira Issues (AM) using those
# 	files.


def getFile()
	puts "---Files in Directory (use .csv)---", `ls | grep csv`, ""
	print "> "
	file = $stdin.gets.chomp
	if file == "*"
		return "*.csv"
	end

	if !(file.include?(".csv")) && !(file.include?("."))
		file += ".csv"		
	else
		Kernel.abort("Wrong file type!")
	end

	if File.exist?(file)
		return file
	else
		Kernel.abort("File doesn't exist!")
	end
end



def main()
	Dir[getFile()].each do |f|
		#if :headers == true
			CSV.foreach(f, headers: true) do |row|
				$_count += 1
				asset_hash = row.to_hash
				issuetype = asset_hash["IssueType"]
				asset_hash = JSON.pretty_generate(asset_hash)
				
				file_name = $_count.to_s + "_" + issuetype + "_hash.json"
				json_file = File.open(file_name, "w")
				json_file.write(asset_hash)
				json_file.close
			end
		#else
		#	Kernel.abort("CSV File doesn't have a header!")
		#end
	end

	if $_count == 0
		puts "No Assets were found!"
	else
		load('searchJiraOSX.rb')
	end
end

$_count = 0
main()