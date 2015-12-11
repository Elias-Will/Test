#!/usr/bin/env ruby

require 'optparse'
require 'json'
require 'stringio'
require 'socket'

$json = false
$csv = false
$csv_no_header = false

op = OptionParser.new do |opts|
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

$messages = {
    'wait_for_device' => 'Waiting for device to be ready. Plug the Android Phone, ensure Developer Mode is enabled',
}

$jira_settings_map = {
    # 'IssueType' => 'Phone',
    'IssueType' => 'Android Phone',
    # 'Summary' => "User is #{$user} @ #{$hostname} (#{$ip})",
    # 'Summary' => "#{$user}s Android",
    'Summary' => "#{$user} ",
    'Project Name' => 'AM',
    'OS' => 'Android'
}

$jira_custom_fields_scripts_map = {
    'Battery Capacity' => 'get_android_battery_capacity.sh',
    'CPU Cores' => 'get_android_device_processor_cores.sh',
    'CPU Model' => 'get_android_device_processor.sh',
    'CPU Speed' => 'get_android_device_processor_speed.sh',
    'Device Name' => 'get_android_device_name.sh',
    'Display Resolution' => 'get_android_device_display_resolution.sh',
    'Display Size' => 'get_android_device_display_size.sh',
    'DPI' => 'get_android_device_display_dpi.sh',
    'IMEI' => 'get_android_imei.sh',
    'MAC Address (Bluetooth)' => 'get_android_bluetooth_mac_address.sh',
    'MAC Address (WIFI)' => 'get_android_wlan_mac_address.sh',
    'Model' => 'get_android_device_model.sh',
    'Manufacturer' => 'get_android_device_manufacturer.sh',
    'OS Version' => 'get_android_build_version.sh',
    'RAM' => 'get_android_device_ram.sh',
    'Serial Number' => 'get_android_serial_number.sh',
    'Bluetooth Version' => 'get_android_bluetooth_version.sh',
    'Bluetooth Chipset' => 'get_android_bluetooth_chipset.sh',
    'Front Camera' => 'get_android_device_front_camera.sh',
    'Rear Camera' => 'get_android_device_rear_camera.sh',
    'SDK Version' => 'get_android_build_sdk.sh',
}

$jira_custom_fields_values_map = {}

$headers = ""
$values = ""

def print_separator
  columns = `stty size | awk '{ print $2 }'`
  columns.to_i.times { print "=" }
end

def check_and_prepare_environment
  `bash osx_install_adb.sh`
end

def block_until_android_is_connected
  puts $messages['wait_for_device']
  `bash wait_for_android.sh`
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

  puts $values
end

def get_jira_json_values
  $jira_settings_map.each { |key, value| $jira_custom_fields_values_map[key] = value}
  $jira_custom_fields_scripts_map.each { |key, script| append_script_value(key,script)}
  $jira_custom_fields_values_map['Summary'] = "#{$jira_custom_fields_values_map['Summary']} #{$jira_custom_fields_values_map['Device Name']}"
  JSON.generate($jira_custom_fields_values_map)
end

def generate_a_summary_file_with_extension(extension)
  get_jira_json_values
  print_separator
  filename = "#{$jira_custom_fields_values_map['Summary']}.#{extension}".gsub(' ','-').gsub('(','').gsub(')','').gsub('/','-').chomp
  puts "Writing output to file: #{filename}"
  # print_separator
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

check_and_prepare_environment
block_until_android_is_connected

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
