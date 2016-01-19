require 'csv'

files = "CSV/*.csv"
csv = CSV.open("Assets.csv", "w")
csv << ["Asset Number", "Purchase Date", "Purchase Cost", "Supplier", "Order Number", "Type",
		"Device Name", "Manufacturer", "Serial Number/IMEI"]

Dir[files].each do |file|
	CSV.foreach(file, headers: true) do |row|
		hash = row.to_hash
		if hash.has_key?("Serial Number")
			csv << [hash["Asset Number"], hash["Purchase Date"], hash["Purchase Cost"], hash["Supplier"], 
			hash["Order Number"], hash["Type"], hash["Device Name"], 
			hash["Manufacturer"], hash["Serial Number"]]
		elsif hash.has_key?("Serial Number/IMEI")
			csv << [hash["Asset Number"], hash["Purchase Date"], hash["Purchase Cost"], hash["Supplier"], 
			hash["Order Number"], hash["Type"], hash["Device Name"], 
			hash["Manufacturer"], hash["Serial Number/IMEI"]]
		elsif hash.has_key?("IMEI")
			csv << [hash["Asset Number"], hash["Purchase Date"], hash["Purchase Cost"], hash["Supplier"], 
			hash["Order Number"], hash["Type"], hash["Device Name"], 
			hash["Manufacturer"], hash["IMEI"]]
		end				
	end
end

csv.close
