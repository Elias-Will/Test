require 'csv'
require 'optparse'
require 'json'


$_continue = false
op = OptionParser.new do |opts|
	#opts.banner = ""
	opts.on('-c', '--cont c', '') { |c| $_continue = true }
	opts.on('-h', '--help', 'Display Help') { puts opts; exit }
end
op.parse

loop do
	puts "############################"
	puts "Asset Number"
	print "> "
	val_asset = $stdin.gets.chomp

	puts "Purchase Date"
	print "> "
	val_date = $stdin.gets.chomp

	puts "Purchase Cost"
	print "> "
	val_cost = $stdin.gets.chomp

	puts "Supplier"
	print "> "
	val_supplier = $stdin.gets.chomp

	puts "Invoice"
	print "> "
	val_invoice = $stdin.gets.chomp

	puts "Type"
	print "> "
	val_type = $stdin.gets.chomp

	puts "Device"
	print "> "
	val_device = $stdin.gets.chomp

	puts "Serial Number/IMEI"
	print "> "
	val_serial = $stdin.gets.chomp

	puts "Manufacturer"
	print "> "
	val_manufacturer = $stdin.gets.chomp


	# val_asset = "PH1601002"
	# val_date = "2016-01-06"
	# val_cost = "386.51"
	# val_supplier = "Telekom"
	# val_invoice = "5038819870"
	# val_device = "Smartphone"
	# val_type = "iPhone 6s 64GB si"
	# val_serial = "355414073789764"
	# val_manufacturer = "Apple"

	to_file = "CSV/" + val_asset.to_s + ".csv"
	next if File.exists?(to_file)
	csv = CSV.open(to_file, "w")
	csv << ["Asset Number", "Purchase Date", "Purchase Cost", "Supplier", "Order Number", "Type",
		"Device Name", "Manufacturer", "Serial Number"]
	csv << [val_asset, val_date, val_cost, val_supplier, val_invoice, val_type, val_device, 
		val_manufacturer, val_serial]
	csv.close

	puts "add another file?"
	print "(y/n)> "
	cont = $stdin.gets.chomp
	cont == "y" ? $_continue = true : $_continue = false
	break if !$_continue
end