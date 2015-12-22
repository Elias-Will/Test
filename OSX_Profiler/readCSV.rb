require 'csv'
require 'json'
require 'optparse'

# 	Reads .csv file(s) from hardware profile
# 	and converts it to a .json hash

$csv_get_all = false
$custom_file = false

op = OptionParser.new do |opts|
	opts.banner = "### readCSV.rb Options ###"
	opts.on('-c', '--customfile filename', 'Extra file') { |filename| $custom_file = filename }
	opts.on('-a', '--all', 'Get all .csv files') { $csv_get_all = true }
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def getFile()	
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
	!$csv_get_all ? files = getFile() : files = "*.csv"
	$count = 0
	Dir[files].each do |f|
		CSV.foreach(f, headers: true) do |row|
			$count += 1
			asset_hash = row.to_hash
			issuetype = asset_hash["IssueType"]
			asset_hash = JSON.pretty_generate(asset_hash)
			
			if $custom_file != false && $custom_file.include?(".json")
				customfile = File.open($custom_file, "w")
				customfile.write(asset_hash)
				customfile.close
			else
				file_name = $count.to_s + "_" + issuetype + "_hash.json"
				json_file = File.open(file_name, "w")
				json_file.write(asset_hash)
				json_file.close
			end
		end		
	end	
end

main()
if $count == 0
	Kernel.abort("No files found!")
end
