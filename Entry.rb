

class Entry

	def initialize form_response
		@name = form_response[1]
		@id = find_company_id
	end

	# Find Chamber's ID for that company
	def find_company_id
		return @name
	end

end