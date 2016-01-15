require 'csv'
require 'json'
require 'optparse'
require '../hash_formatter'

# 	Reads .csv file(s) from hardware profile
# 	and converts it to a .json hash

$get_all_csv = false
$custom_file = false
$file_count = 0

op = OptionParser.new do |opts|
	opts.banner = "### readCSV.rb Options ###"
	opts.on('-c', '--customfile filename', 'Extra file') { |filename| $custom_file = filename }
	opts.on('-a', '--all', 'Get all .csv files') { $get_all_csv = true }
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

def get_file_name()
	print "> "
	file_name = $stdin.gets.chomp	
	return "*.csv" if file_name == "*"	

	if !(file_name.include?(".csv")) && !(file_name.include?("."))
		file_name += ".csv"
	else
		Kernel.abort("Wrong file type!")
	end

	if File.exist?(file_name)
		return file_name
	else
		Kernel.abort("#{file_name} doesn't exist!")
	end
end

def main()
	!$get_all_csv ? files = get_file_name() : files = "*.csv"
	Dir[files].each do |file|
		CSV.foreach(file, headers: true) do |row|
			$file_count += 1
			asset_hash = row.to_hash
			asset_type = asset_hash["IssueType"]
			asset_hash = JSON.pretty_generate(asset_hash)
			
			if $custom_file != false && $custom_file.include?(".json")
				CreateHash.create_hash_file($custom_file, asset_hash)
			else
				file_name = $file_count.to_s + "_" + asset_type + "_hash.json"
				CreateHash.create_hash_file(file_name, asset_hash)
			end
		end		
	end	
end

main()
Kernel.abort("No files found!") if $file_count == 0

