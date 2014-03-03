# Class for modeling Users
class User < ActiveRecord::Base
	# callback to force email to lowercase for uniqueness
	before_save { self.email = email.downcase }
	# validates the uniqueness of the email address, disregarding lettercase
	validates :email, uniqueness: { case_sensitive: false }
	# method call to return hashed password_digest from password to be stored in db
	#     no value set to password_confirmation (password_confirmation designed to be done in frontend)
	has_secure_password

  # The maximum length of any user credential field
  @@MAX_CREDENTIAL_LENGTH = 128
  # The minimum length of password field
  @@MIN_PW_LENGTH = 6
  # name format only contains letter or whitespace characters
	@@VALID_NAME_REGEX = /\A[a-zA-z\.']+(\s[a-zA-z\.']+)*\z/
	# email format is [word characters and dashes][@][domain]
	@@VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	# Success return code
	@@SUCCESS = 1
	# Invalid name: must be VALID_NAME_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
	@@ERR_INVALID_NAME = -1
	# Invalid email: must be VALID_EMAIL_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
	@@ERR_INVALID_EMAIL = -2
	# Password cannot be longer than MAX_CREDENTIAL_LENGTH or shorter than MIN_PW_LENGTH
	@@ERR_INVALID_PASSWORD = -3
	# Email is not unique (i.e. exists already in database)
	@@ERR_EMAIL_TAKEN = -4
	# Cannot find the email/password pair in the database (i.e. login fail)
	@@ERR_BAD_CREDENTIALS = -5
	# Generic error for an invalid property
	@@ERR_INVALID_FIELD = -6
	# Generic error for an unseccessful action
	@@ERR_UNSUCCESSFUL = -7


	#private # all following methods will be made private

	def validate_name
		if name == nil
			return @@ERR_INVALID_NAME
		elsif @@VALID_NAME_REGEX !~ name || name.empty? || name.length > @@MAX_CREDENTIAL_LENGTH
			return @@ERR_INVALID_NAME
		end
		@@SUCCESS
	end
				

	def validate_email
		if email == invalid
			return @@ERR_INVALID_EMAIL
		elsif @@VALID_EMAIL_REGEX !~ email || email.empty? || email.length > @@MAX_CREDENTIAL_LENGTH
			return @@ERR_INVALID_EMAIL
		elsif not valid?
			return @@ERR_EMAIL_TAKEN
		end
		@@SUCCESS
	end

	# work on this method
	def validate_password
		if password == nil
			return @@ERR_INVALID_PASSWORD
		elsif password.length < @@MIN_PW_LENGTH || password.length > @@MAX_CREDENTIAL_LENGTH
			return @@ERR_INVALID_PASSWORD
		@@SUCCESS
	end

end
