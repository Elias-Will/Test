class Address

	@address = ""
	@search_address = ""
	@create_address = ""

	def initialize()
		@protocol = "https"
		@host = "kupferwerk.atlassian.net"
		@api = "rest/api/latest/"
		createAddress()
	end

	def setProtocol(p)
		@protocol = p
		createAddress()
	end

	def setHost(h)
		@host = h
		createAddress()
	end

	def setAPI(a)
		@api = a
		createAddress()
	end

	def createAddress()
		@address = @protocol + "://" + @host + "/" + @api
		@search_address = @address + "search"
		@create_address = @address + "issue"
	end
end


