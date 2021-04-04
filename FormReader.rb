require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'time'

class FormReader
	attr_accessor :new_entries

	def initialize
		@service = start_service
		@new_entries = find_new_entries
	end #initialize

	# Starts the service to talk to Google Sheets
	def start_service
		service = Google::Apis::SheetsV4::SheetsService.new
		service.client_options.application_name = "NY-Chamber".freeze
		service.authorization = authorize
		return service
	end #start_service

	# give the @service authorization
	def authorize
		client_id = Google::Auth::ClientId.from_file "credentials.json".freeze
		scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
		token_store = Google::Auth::Stores::FileTokenStore.new file: "token.yaml".freeze

		authorizer = Google::Auth::UserAuthorizer.new client_id, scope, token_store
		user_id = "default"
		credentials = authorizer.get_credentials user_id

		return credentials
	end #authorize

	# convert sheets time to Time object
	def format_time(time_string)
		date, time = time_string.split
		m, d, y = date.split("/")
		t = Time.parse("#{y}-#{m}-#{d} #{time}")
		return t
	end

	# get the age (in seconds) of time string 
	def age(time_string)
		return Time.now() - format_time(time_string) 
	end

	# finds entries by age
	# default 5 mins
	def find_new_entries max_age=300, range="Form Responses 1!A2:D"
		spreadsheet_id = "16oTQynVjUWo2I6JZJHey3rqvSNKgAt6cxwHcskmScSY"
		new_entries = []

		response = @service.get_spreadsheet_values spreadsheet_id, range
		response.values.each {|row| new_entries.push row if age(row[0]) <= max_age}

		return new_entries
	end
	
end #class