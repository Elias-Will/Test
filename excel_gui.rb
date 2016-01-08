require "wx"

class Frame < Wx::Frame
	include Wx

	def initialize(parent = nil)
		super(parent, :size => Size.new(400, 400), :title => "test")
		self.background_color = NULL_COLOUR

		StaticText.new(self, :label => "testlabel1", :pos => Point.new(20, 20))
		StaticText.new(self, :label => "testlabel2", :pos => Point.new(50, 20))
	end
end

class App > Wx::App
	include Wx

	def on_init
		@mainwindow = Frame.new
		@mainwindow.show
	end
end