require 'writeexcel'
#require 'wx'
require './excel_stylesheet'
require 'csv'
#require './excel_gui'

#5 10 20

dir = "csv/IT0912008.csv"
Dir[dir].each do |file|
	CSV.foreach(file, headers: true) do |row|
		hash = row.to_hash

###placeholder
val_asset = hash["Asset Number"].to_s
val_date = hash["Purchase Date"]
val_cost = hash["Purchase Cost"]
val_supplier = hash["Supplier"]
val_invoice = hash["Order Number"]
val_device = hash["Type"]
val_type = hash["Device Name"]
val_serial = hash["Serial Number/IMEI"]
val_manufacturer = hash["Manufacturer"]

if val_serial == nil
	workbook = WriteExcel.new("xls/" + val_asset + " - keine SN.xls")
else
	workbook = WriteExcel.new("xls/" + val_asset + ".xls")
end

######################
worksheet = workbook.add_worksheet

FormatCells.set_cell_size(worksheet)
FormatCells.merge_blanks(workbook, worksheet)

#Head
worksheet.merge_range('A1:G2', 'Anlagenkartei', FormatCells.format_head(workbook))

#Subhead
format = FormatCells.format_sub_head(workbook)
format.set_right(1)
worksheet.merge_range('D3:G3', 'Inventar-Nr', format)

format = FormatCells.format_sub_head_value(workbook)
format.set_right(1)
worksheet.merge_range('D4:G4', val_asset, format)

format = FormatCells.format_sub_head_value(workbook)
format.set_left(1)
worksheet.merge_range('A4:B4', 'Regensburg/München', format)

format = FormatCells.format_sub_head(workbook)
format.set_left(1)
worksheet.merge_range('A3:B3', 'Kupferwerk GmbH', format)

worksheet.write('C4', nil, FormatCells.format_sub_head_value(workbook)) #blank

#Body
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
worksheet.merge_range('B6:C6', val_date, format)
worksheet.merge_range('B7:C7', val_cost, format)
worksheet.merge_range('B8:C8', val_supplier, format)
worksheet.merge_range('B9:C9', val_invoice, format)

worksheet.merge_range('F6:G6', val_device, format)
worksheet.merge_range('F7:G7', val_type, format)
worksheet.merge_range('F8:G8', val_serial, format)
worksheet.merge_range('F9:G9', val_manufacturer, format)

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