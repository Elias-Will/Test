require 'rubyXL'
require 'csv'
require 'json'

# 	1) Creates .csv from .xlsx with
# 	   'customfield_...' & formatted date
# 	2) Converts price to decimal value
# 	3) Creates .json hash for matching
# 	4) Creates .json hash & deletes spaces
# 	   for curl command

_file_cout = 0
_xlsx_dir = "../AfA-Karteien (bearb)/*.xlsx"

begin
	Dir[_xlsx_dir].each do |_xlsx_file|
		_file_cout += 1
		puts "Count: #{_file_cout}"

		workbook = RubyXL::Parser.parse(_xlsx_file)
		_xlsx_data = workbook.worksheets[0]

		_inv_key = _xlsx_data.sheet_data[2][3].value.chop
		_inv_val = _xlsx_data.sheet_data[3][3].value.to_s

		_date_purchase_key = _xlsx_data.sheet_data[5][0].value.chop
		_date_purchase_val = _xlsx_data.sheet_data[5][1].value.to_s

		#creates date of form yyyy-mm-dd
		_date_purchase_val.include?('-') ? format = false : format = true
		if format == true #case dd.mm.yyyy || dd.mm.yy
			_date_purchase_val = Date.strptime(_date_purchase_val, 
				"%d.%m.%Y").strftime("%F").to_s
		elsif format == false #case yyyy-mm-ddT...
			_date_purchase_val = Date.strptime(_date_purchase_val, 
				"%Y-%m-%dT%H:%M:%S%z").to_s
			_date_purchase_val = Date.strptime(_date_purchase_val, 
				"%Y-%m-%d").strftime("%F").to_s
		end

		#if year is of from 'yy-mm-dd', .strftime("%F") saves
		#it as '00yy-mm-dd'
		if _date_purchase_val[0] == "0" && _date_purchase_val[1] == "0"
			_date_purchase_val[0] = "2"
		end

		_cost_purchase_key = _xlsx_data.sheet_data[6][0].value.chop
		_cost_purchase_val = _xlsx_data.sheet_data[6][1].value.to_f

		_supplier_key = _xlsx_data.sheet_data[7][0].value.chop
		_supplier_val = _xlsx_data.sheet_data[7][1].value.to_s

		_invoice_key = _xlsx_data.sheet_data[8][0].value.chop
		_invoice_val = _xlsx_data.sheet_data[8][1].value.to_s

		_device_key = _xlsx_data.sheet_data[5][3].value.chop
		_device_val = _xlsx_data.sheet_data[5][5].value.to_s

		_type_key = _xlsx_data.sheet_data[6][3].value.chop
		_type_val = _xlsx_data.sheet_data[6][5].value.to_s

		_serial_key = _xlsx_data.sheet_data[7][3].value.chop
		_serial_val = _xlsx_data.sheet_data[7][5].value	
		next if _serial_val == nil
		_serial_val.to_s
		if _serial_val[0] == "S"
			if _serial_val[1] == "C"
				_serial_val.slice!(0)
			elsif _serial_val[1] == "W"
				_serial_val.slice!(0)
			elsif _serial_val[1] == "G"
				_serial_val.slice!(0)
			elsif _serial_val[1] == "D"
				_serial_val.slice!(0)
			elsif _serial_val[1] == "F"
				_serial_val.slice!(0)
			elsif _serial_val[1] == "V"
				_serial_val.slice!(0)
			end
		end					
		#SC SW SG SD SV? SF 

		_manufacturer_key = _xlsx_data.sheet_data[8][3].value.chop
		_manufacturer_val = _xlsx_data.sheet_data[8][5].value.to_s


		#saves as .csv
		_asset_type = _inv_val.slice(0..1) #PH/LA...
		_csv_dir = "t_csv/" + _inv_val + ".csv"
		_csv = CSV.open(_csv_dir, "w")
		#Phones use IMEI instead of Serial Number
			if _asset_type == 'PH'			
				_csv << ["customfield_11009", "customfield_11005", "customfield_11006",
				"customfield_11010", "customfield_11008", "customfield_11211", "customfield_11003", 
				"customfield_11201"]
			else 
				_csv << ["customfield_11009", "customfield_11005", "customfield_11006",
				"customfield_11010", "customfield_11008", "customfield_11211", "customfield_11003", 
				"customfield_11002"]
			end
			
			_csv << [_inv_val, _date_purchase_val, _cost_purchase_val, _supplier_val, _invoice_val, 
				_type_val, _manufacturer_val, _serial_val]		
		_csv.close
		#CSV.foreach(_csv_dir, headers: true) do |_row|
			#_hash = _row.to_hash
			#_hash["customfield_11009"] #Asset Number
			#_hash["customfield_11005"] #Purchase Date
			#_hash["customfield_11006"] #Purchase Cost
			#_hash["customfield_11010"] #Supplier
			#_hash["customfield_11008"] #Invoice
			#_hash["customfield_11211"] #Device Name
			#_hash["customfield_11003"] #manufacturer
			#_hash["customfield_11002"] #Serial Number
			#_hash["customfield_11201"] #IMEI
			_JSON_curl_unformatted = {
				"fields" => {
					"customfield_11009" => _inv_val,
					"customfield_11005" => _date_purchase_val,
					"customfield_11006" => _cost_purchase_val,
					"customfield_11010" => _supplier_val,
					"customfield_11008" => _invoice_val
				}
			}
			_JSON_curl_unformatted = JSON.pretty_generate(_JSON_curl_unformatted)
			_JSON_curl_formatted = _JSON_curl_unformatted.gsub(/\s+/, "")
			_JSON_dir = "t_json/" + _inv_val + "_curl.json"
			_JSON_file = File.open(_JSON_dir, 'w')
			_JSON_file.write(_JSON_curl_formatted)
			_JSON_file.close

			
			if _asset_type == 'PH'
				_JSON_match = {
					"customfield_11009" => _inv_val,
					"customfield_11201" => _serial_val.to_s
				}
			else
				_JSON_match = {
					"customfield_11009" => _inv_val,
					"customfield_11002" => _serial_val.to_s
				}
			end

			_JSON_match = JSON.pretty_generate(_JSON_match)
			_JSON_dir = "t_json/" + _inv_val + "_match.json"
			_JSON_file = File.open(_JSON_dir, 'w')
			_JSON_file.write(_JSON_match)
			_JSON_file.close

	end
rescue Exception => msg
	puts ""
	puts msg
end


