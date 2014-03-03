# Class for modeling Users
class User < ActiveRecord::Base
	# callback to force email to lowercase for uniqueness
	before_save { self.email = email.downcase }
	# validates the uniqueness of the email address, disregarding lettercase
	validates :email, uniqueness: { case_sensitive: false }

  # The maximum length of any user credential field
  @@MAX_CREDENTIAL_LENGTH = 128
  # name format only contains letter, number, underscore, or whitespace characters
	@@VALID_NAME_REGEX = /\A[\w,\s]+\z/
	# email format is [word characters and dashes][@][domain]
	@@VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	# Success return code
	@@SUCCESS = 1
	# Cannot find the email/password pair in the database (i.e. login fail)
	@@ERR_BAD_CREDENTIALS = 11
	# Invalid name: must be VALID_NAME_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
	@@ERR_BAD_NAME = 12
	# Invalid email: must be VALID_EMAIL_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
	@@ERR_BAD_EMAIL = 13



	#private # all following methods will be made private

	def validate_name
		if @@VALID_NAME_REGEX !~ name || name.empty? || name.length > @@MAX_CREDENTIAL_LENGTH
			return @@ERR_BAD_NAME
		end
		@@SUCCESS
	end
				

	def validate_email
		if @@VALID_EMAIL_REGEX !~ email || email.empty? || email.length > @@MAX_CREDENTIAL_LENGTH
			return @@ERR_BAD_EMAIL
		end
		@@SUCCESS
	end

	def validate_password
		@@SUCCESS
	end

end
