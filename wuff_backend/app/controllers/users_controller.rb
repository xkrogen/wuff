class UsersController < ApplicationController
	
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

  def do_add

  end

  def do_login

  end
end
