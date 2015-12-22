require 'csv'
require 'json'
require 'optparse'
require 'logger'

$csv_get_all = false
$extra_file = false

op = OptionParser.new do |opts|
	#opts.banner
	opts.on('-e', '--add filename', 'Extra file') { |filename| $extra_file = filename }
	opts.on('-a', '--all', 'Get all .csv files') { $csv_get_all = true }
	opts.on('-h', '--help', 'Display Help') do
		puts opts
		exit
	end
end
op.parse!

$log = Logger.new 'log.txt'
$log.datetime_format = '%F %H:%M:%S'


def getFile()
	file = $stdin.gets.chomp
	if file == "*"
		$log.info "File(s) used: " + Dir.glob("*.csv").to_s
		return "*.csv"
	end

	if !(file.include?(".csv")) && !(file.include?("."))
		file += ".csv"		
	else
		$log.error "Wrong file type! File: " + file
		Kernel.abort("Wrong file type!")
	end

	if File.exist?(file)
		$log.info "File used: " + file
		return file
	else
		$log.error "File doesn't exist! File: " + file
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
				issuetype = "Android"#asset_hash["IssueType"]
				asset_hash = JSON.pretty_generate(asset_hash)
				
				file_name = $count.to_s + "_" + issuetype + "_hash.json"
				$log.info "Created json-file " + file_name
				json_file = File.open(file_name, "w")
				json_file.write(asset_hash)
				json_file.close

				if $extra_file != false && $extra_file.include?(".json")
					extrafile = File.open($extra_file, "a")
					extrafile.write(asset_hash)
					extrafile.close
				end
			end
	end	
end

main()
if $count == 0
	$log.error "No files found!"
	Kernel.abort("No files found!")
end