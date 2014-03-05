# Class for modeling Users
class User < ActiveRecord::Base
	# callback to force email to lowercase for uniqueness
	before_save { self.email = email.downcase }
	# validates the uniqueness of the email address, disregarding lettercase
	validates :email, uniqueness: { case_sensitive: false }
	# method call to return hashed password_digest from password to be stored in db
	#     validation off for empty password and password_confirmation (password_confirmation designed to be done in frontend)
	has_secure_password validations: false

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


	# Function checks that the user does not exist, the user name, email, and password format is correct
	# * On Success the function adds a row to the DB
	# * On success the result is success code: SUCCESS
	# * On failure the result is an error code (<0): 	ERR_INVALID_NAME, ERR_INVALID_EMAIL, ERR_EMAIL_TAKEN, ERR_INVALID_PASSWORD
	def add
		return @@ERR_INVALID_NAME if not name_valid?
		return @@ERR_INVALID_EMAIL if not email_valid?
		return @@ERR_INVALID_PASSWORD if not password_valid?
		return @@ERR_EMAIL_TAKEN if not email_available?
		#save
		@@SUCCESS
	end


	private # all following methods will be made private

  # Function that checks if name is formatted correctly
  # * Return true if name matches VALID_NAME_REGEX, name exists, length non-empty and less than MAX_CREDENTIAL_LENGTH
	def name_valid?
		if name == nil
			return false
		elsif @@VALID_NAME_REGEX !~ name || name.empty? || name.length > @@MAX_CREDENTIAL_LENGTH
			return false
		end
		true
	end
				
	# Function that checks if email is formatted correctly
	# * Return true if email matches VALID_EMAIL_REGEX, email exists, length non-empty and less than @@MAX_CREDENTIAL_LENGTH
	def email_valid?
		if email == nil
			return false
		elsif @@VALID_EMAIL_REGEX !~ email || email.empty? || email.length > @@MAX_CREDENTIAL_LENGTH
			return false
		end
		true
	end

	# Function that checks if email name is unique
	# * Return true if email does not exist in db
	def email_available?
		self.valid?
	end

	# Function that checks if password is formatted correctly
	# * Return truf if password exists, length greater than MIN_PW_LENGTH and less than MAX_CREDENTIAL_LENGTH
	def password_valid?
		if password == nil
			return false
		elsif password.length < @@MIN_PW_LENGTH || password.length > @@MAX_CREDENTIAL_LENGTH
			return false
		end
		true
	end
end
