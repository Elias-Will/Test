#!/usr/bin/env ruby

require 'optparse'
require 'json'
require 'stringio'
require 'socket'

$json = false
$csv = false
$csv_no_header = false

op = OptionParser.new do |opts|
  # opts.banner = 'Usage: osx_profiler_for_kupferwerk_jira.rb [opts]'
  opts.on('--file', '-f', 'Creates a resulting file') {|file| $file = file }
  opts.on('--json', '-j', 'Get output in JSON format') {|json| $json = json }
  opts.on('--csv', '-c', 'Get output in CSV format for Jira') {|csv| $csv = csv }
  opts.on('--quiet', '-q', 'Do not print CSV headers') { |headers| $csv_no_header = headers }
  opts.on('--help', '-h', 'Prints this help') { puts opts; exit }
  opts.parse!
end

### Variable Mappings

$user = ENV['USER']
$hostname = Socket.gethostname
$ip = Socket.ip_address_list[4].ip_address

$jira_settings_map = {
    'IssueType' => 'Laptop',
    'Summary' => "User is #{$user} @ #{$hostname} (#{$ip})",
    'Project Name' => 'AM',
    'manufacturer' => 'Apple',
    'OS' => 'Mac OS X'
}

$jira_custom_fields_scripts_map = {
    'Battery Capacity' => 'osx_get_battery.sh',
    'CPU Cores' => 'osx_get_cpu_cores.sh',
    'CPU Model' => 'osx_get_cpu_model.sh',
    'CPU Speed' => 'osx_get_cpu_speed.sh',
    'Display Resolution' => 'osx_get_display_resolution.sh',
    'Firewire Ports' => 'osx_get_firewire.sh',
    'Graphics Card 1' => 'osx_get_graphics_card_1.sh',
    'Graphics Card 2' => 'osx_get_graphics_card_2.sh',
    'Internal Storage Capacity' => 'osx_get_internal_storage_capacity.sh',
    'MAC Address (Bluetooth)' => 'osx_get_mac_address_bluetooth.sh',
    'MAC Address (Ethernet)' => 'osx_get_mac_address_ethernet.sh',
    'MAC Address (WIFI)' => 'osx_get_mac_address_airport.sh',
    'Model' => 'osx_get_model_short.sh',
    'Number of Thunderbolt Ports' => 'osx_get_thunderbolt_number_of_ports.sh',
    'OS Version' => 'osx_get_version.sh',
    'Power Supply (Energy)' => 'osx_get_power_supply.sh',
    'RAM' => 'osx_get_ram_amount.sh',
    'RAM Speed' => 'osx_get_ram_speed.sh',
    'RAM Upgradeable' => 'osx_get_ram_upgradeable.sh',
    'Serial Number' => 'osx_get_serial_number.sh',
    'Storage Type' => 'osx_get_storage_type.sh',
    'Thunderbolt Type' => 'osx_get_thunderbolt_speed.sh',
    'USB Type' => 'osx_get_usb_type.sh',
    'VRAM' => 'osx_get_vram.sh',
}

$jira_custom_fields_values_map = {}

$headers = ""
$values = ""

def print_separator
  columns = `stty size | awk '{ print $2 }'`
  columns.to_i.times { print "=" }
end

def get_hostname
  Socket::getaddrinfo(Socket.gethostname)
end

def append_script_value(key,script)
  if File.file?(script)
    $jira_custom_fields_values_map[key] = `bash #{script}`.chomp
  end
end

def set_jira_csv_project_headers
  $jira_settings_map.each do |key,value|
    (key.to_s.include? ' ') ? header = "\"#{key}\"" : header = key
    $headers += "#{header},"

    (value.to_s.include? ' ') ? val = "\"#{value}\"" : val = value
    $values += "#{val},"
  end
end

def get_jira_csv_asset_headers_and_values
  $jira_custom_fields_scripts_map.each do |key,script|
    (key.to_s.include? ' ') ? header = "\"#{key}\"" : header = key
    $headers += "#{header},"
    if (File.file?(script))
      value = `bash #{script}`.chomp
    else
      value = ''
    end
    value = "\"#{value}\"" if (value.to_s.include? ' ')
    $values += "#{value},"
  end
end

def get_jira_csv_values
  set_jira_csv_project_headers
  get_jira_csv_asset_headers_and_values

  ### Cleanup the last comma
  $headers = $headers[0..-2]
  $values = $values[0..-2]

  if $csv_no_header == false
    puts $headers
  end
  # puts $headers
  puts $values
end

def get_jira_json_values
  $jira_settings_map.each { |key, value| $jira_custom_fields_values_map[key] = value}
  $jira_custom_fields_scripts_map.each { |key, script| append_script_value(key,script)}
  JSON.generate($jira_custom_fields_values_map)
end

def generate_a_summary_file_with_extension(extension)
  get_jira_json_values
  print_separator
  filename = "#{$jira_custom_fields_values_map['Summary']}.#{extension}".gsub(' ','-').gsub('(','').gsub(')','').gsub('/','-').chomp
  puts "Writing output to file: #{filename}"
  case extension
    when "json"
      File.open("#{filename}", 'w+') { |file| file.write(get_jira_json_values) }
    when "csv"
      # Save old Stdout
      old_stdout = $stdout
      # Set up standard output as a StringIO object.
      csvoutput = StringIO.new
      # Redirect Output to new IO Stream
      $stdout = csvoutput
      # Get the values
      get_jira_csv_values
      # Return to old Stdout
      $stdout = old_stdout

      # csvoutput.string
      File.open("#{filename}", 'w+') { |file| file.write(csvoutput.string) }
  end

end

if !($json || $csv || $file)
  puts 'No output format specified. Nothing dome.'
  puts op.help
  exit
end


# if $json
#   print_separator unless ($csv_no_header || $file)
#   puts get_jira_json_values
# end
#
# if $csv
#   print_separator unless ($csv_no_header || $file)
#   get_jira_csv_values
# end
#
# if $file
#   print_separator unless $csv_no_header
#   if !($json || $csv)
#     print_separator
#     puts "No specific Format selected, generating both JSON and CSV files"
#     get_jira_csv_values
#     get_jira_json_values
#     generate_a_summary_file_with_extension "csv"
#     generate_a_summary_file_with_extension "json"
#   end
#   if $json
#     print_separator
#     puts "Generating JSON file"
#     generate_a_summary_file_with_extension "json"
#   end
#   if $csv
#     print_separator
#     puts "Generating CSV file"
#     generate_a_summary_file_with_extension "csv"
#   end
#   if (($json || $csv) && $file)
#     print_separator
#   end
# end


if $json and ! $file
  print_separator unless $csv_no_header
  puts get_jira_json_values
end

if $csv and ! $file
  print_separator unless $csv_no_header
  get_jira_csv_values
end

if $file
  print_separator unless $csv_no_header
  if !($json || $csv)
    print_separator
    puts "No specific Format selected, generating both JSON and CSV files"
    generate_a_summary_file_with_extension "csv"
    # print_separator
    generate_a_summary_file_with_extension "json"
    # print_separator
    # get_jira_csv_values
    # get_jira_json_values
  end
  if $json
    print_separator
    puts "Generating JSON file"
    generate_a_summary_file_with_extension "json"
  end
  if $csv
    print_separator
    puts "Generating CSV file"
    generate_a_summary_file_with_extension "csv"
  end
end

print_separator unless $csv_no_header
