require 'csv'
require 'json'

files = "CSV/*.csv"
Dir[files].each do |file|
	CSV.foreach(file, headers: true) do |row|
		h = row.to_hash
		_asset = h["Asset Number"]
		# _date = h["Purchase Date"]
		# _cost = h["Purchase Cost"]
		# _supplier = h["Supplier"]
		# _invoice = h["Order Number"]
		# _type = h["Type"]
		# _device = h["Device Name"]
		# _manufacturer = h["Manufacturer"]
		# _serial = h["Serial Number"] #can also be IMEI
		if h.has_key?("Serial Number/IMEI")
			temp = h["Serial Number/IMEI"]
			h.delete("Serial Number/IMEI")
			h.store("Serial Number", temp)
		end

		json_file = "JSON/" + _asset.to_s + ".json"
		break if File.exists?(json_file)
		jfile = File.open(json_file, 'w')
		jfile.write("{\"fields\":")
		jfile.puts JSON.pretty_generate(h)
		jfile.write("}")
	end
end
