module FormatCells

	def self.set_cell_size(worksheet)
		worksheet.set_column('A:A', 15)
		worksheet.set_column('B:B', 8)
		worksheet.set_column('C:C', 9)
		worksheet.set_column('D:D', 8)
		worksheet.set_column('E:E', 8)
		worksheet.set_column('F:F', 1)
		worksheet.set_column('G:G', 25)

		worksheet.set_row(0, 12)
		worksheet.set_row(1, 12)
		worksheet.set_row(2, 22)
		worksheet.set_row(3, 22)
		worksheet.set_row(4, 7)
		for i in 5..8
			worksheet.set_row(i, 19)
		end
		worksheet.set_row(9, 7)
		worksheet.set_row(10, 19)
		for i in 11..18
			worksheet.set_row(i, 17)
		end
		worksheet.set_row(19, 7)
		worksheet.set_row(20, 18)
		worksheet.set_row(21, 12)
		for i in 22..32
			worksheet.set_row(i, 17)
		end
		return worksheet
	end

	def self.merge_blanks(workbook, worksheet)
		f_format = workbook.add_format(:font => 'Arial') #font set so compiler doesn't complain
		worksheet.merge_range('A5:G5', nil, f_format)
		worksheet.merge_range('A10:G10', nil, f_format)
		worksheet.merge_range('A20:G20', nil, f_format)
		return worksheet
	end

	def self.format_head(workbook)
		f_color = workbook.set_custom_color(40, '#A9BCF5') #has to be slightly brighter
		f_format = workbook.add_format(	:align => 'center',
										:valign => 'vcenter',
										:size => 16,
										:font => 'Arial',
										:fg_color => 40,
										:border => 1)
		return f_format
	end

	def self.format_sub_head(workbook)
		f_format = workbook.add_format(	:align => 'center',
										:valign => 'vcenter',
										:size => 10,
										:font => 'Arial',
										:bold => 1)
		return f_format
	end

	def self.format_sub_head_value(workbook)
		f_format = workbook.add_format(	:align => 'center',
										:valign => 'vcenter',
										:size => 10,
										:font => 'Arial',
										:bottom => 1)
		return f_format
	end

	def self.format_body_key(workbook)
		f_format = workbook.add_format(	#:align => 'center',
										:valign => 'vcenter',
										:size => 10,
										:font => 'Arial',
										:border => 1,
										:fg_color => 'yellow')
		return f_format
	end

	def self.format_body_value(workbook)
		f_format = workbook.add_format(	:align => 'center',
										:valign => 'vcenter',
										:size => 10,
										:font => 'Arial',
										:border => 1)
		return f_format
	end
end





