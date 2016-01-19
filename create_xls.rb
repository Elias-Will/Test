require 'csv'
require 'json'
require 'optparse'
require 'writeexcel'
require './excel_stylesheet'


op = OptionParser.new do |opts|
	#opts.banner = ""
	opts.on('-c', '--cont c', '') { |c| $_continue = true }
	opts.on('-h', '--help', 'Display Help') { puts opts; exit }
end
op.parse!

files = "CSV/*.csv"
Dir[files].each do |file|
	CSV.foreach(file, headers: true) do |row|
		h = row.to_hash
		_asset = h["Asset Number"]
		_date = h["Purchase Date"]
		_cost = h["Purchase Cost"]
		_supplier = h["Supplier"]
		_invoice = h["Order Number"]
		_type = h["Type"]
		_device = h["Device Name"]
		_manufacturer = h["Manufacturer"]
		if h.has_key?("Serial Number")
			_serial = h["Serial Number"]
		elsif h.has_key?("Serial Number/IMEI")
			_serial = h["Serial Number/IMEI"]
		elsif h.has_key?("IMEI")
			_serial = h["IMEI"]
		end				

		break if Dir.glob("XLS/" + _asset + "*.xls").any?
		if _serial == nil || _serial.empty?
		 	file_name = "XLS/" + _asset + " - keine SN, ohne Rechnung.xls"
			workbook = WriteExcel.new(file_name)
		else			
			file_name = "XLS/" + _asset.to_s + " - ohne Rechnung.xls"
			workbook = WriteExcel.new(file_name)
		end

		######################
		worksheet = workbook.add_worksheet
		worksheet.hide_gridlines(2)

		FormatCells.set_cell_size(worksheet)
		FormatCells.merge_blanks(workbook, worksheet)

		
		worksheet.merge_range('A1:G2', 'Anlagenkartei', FormatCells.format_head(workbook))
		
		format = FormatCells.format_sub_head(workbook)
		format.set_right(1)
		worksheet.merge_range('D3:G3', 'Inventar-Nr', format)

		format = FormatCells.format_sub_head_value(workbook)
		format.set_right(1)
		worksheet.merge_range('D4:G4', _asset, format)

		format = FormatCells.format_sub_head_value(workbook)
		format.set_left(1)
		worksheet.merge_range('A4:B4', 'Regensburg/München', format)

		format = FormatCells.format_sub_head(workbook)
		format.set_left(1)
		worksheet.merge_range('A3:B3', 'Kupferwerk GmbH', format)

		worksheet.write('C4', nil, FormatCells.format_sub_head_value(workbook)) #blank

		format = FormatCells.format_body_key(workbook)
		worksheet.write('A6', 'Anschaffung', format)
		worksheet.write('A7', 'Anschaffungspreis', format)
		worksheet.write('A8', 'Rechnung', format)
		worksheet.write('A9', 'Rechnungs-Nr', format)

		format = FormatCells.format_body_key(workbook)
		format.set_align('center')
		worksheet.merge_range('D6:E6', 'Gerät', format)
		worksheet.merge_range('D7:E7', 'Typ', format)
		worksheet.merge_range('D8:E8', 'SerienNr', format)
		worksheet.merge_range('D9:E9', 'Hersteller', format)

		format = FormatCells.format_body_value(workbook)
		worksheet.merge_range('B6:C6', _date, format)
		worksheet.merge_range('B7:C7', _cost, format)
		worksheet.merge_range('B8:C8', _supplier, format)
		worksheet.merge_range('B9:C9', _invoice, format)

		worksheet.merge_range('F6:G6', _type, format)
		worksheet.merge_range('F7:G7', _device, format)
		worksheet.merge_range('F8:G8', _serial, format)
		worksheet.merge_range('F9:G9', _manufacturer, format)

		format = FormatCells.format_body_key(workbook)
		format.set_align('center')
		worksheet.merge_range('A11:B11', 'Benutzer', format)
		worksheet.merge_range('C11:E11', 'Von', format)
		worksheet.merge_range('F11:G11', 'Bis', format)
		worksheet.merge_range('A22:B22', 'Jahr', format)
		worksheet.merge_range('C22:G22', 'AfA-Satz', format)

		format = FormatCells.format_body_key(workbook)
		format.set_align('center')
		format.set_size(14)
		worksheet.merge_range('A21:G21', 'Abschreibung', format)

		format = FormatCells.format_body_value(workbook)
		for index in 12..19
			worksheet.merge_range("A#{index}:B#{index}", nil, format)
		end

		for index in 12..19
			worksheet.merge_range("C#{index}:E#{index}", nil, format)
		end

		for index in 12..19
			worksheet.merge_range("F#{index}:G#{index}", nil, format)
		end

		for index in 23..33
			worksheet.merge_range("A#{index}:B#{index}", nil, format)
		end

		for index in 23..33
			worksheet.merge_range("C#{index}:G#{index}", nil, format)
		end
		workbook.close
	end	
end






