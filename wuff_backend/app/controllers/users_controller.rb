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

	# POST /user/add_user
	# Tries to store user in db using User#add
	# * On success, stores user in database
	# * On success, stores cookie to remember session and sets the current_user to this user
	# * On success, returns JSON { :err_code, : user_id }
	# * On failure, returns JSON { :err_code }
  def add_user
  	@user = User.new(name: params[:name], email: params[:email], password: params[:password])
    rval = @user.add
  	if rval < 0
      respond(rval)
  	else
  		token = User.new_token
  		cookies.permanent[:current_user_token] = token
  		user.update_attribute(:remember_token, User.hash(token))
  		self.current_user = @user
      respond(rval, { user_id: current_user.id })
  	end
  end

  # POST /user/login_user
  # Tries to login user in using User#login
	# * On success, stores cookie to remember session and sets the current_user to this user
	# * On success, returns JSON { :err_code, : user_id }
	# * On failure, returns JSON { :err_code }
  def login_user
  	@user = User.new(email: params[:email], password: params[:password])
  	rval = @user.login
  	if rval[:err_code] < 0
      respond(rval[:err_code])
  	else
  		@user = rval[:user]
  		token = User.new_token
  		cookies.permanent[:current_user_token] = token
  		user.update_attribute(:remember_token, User.hash(token))
  		self.current_user = @user
      respond(rval[:err_code], { user_id: current_user.id })
  		end
  	end
  end

  # POST /user/logout_user
  # Logout the current_user
  # * Changes current_user's remember_token in database
  # * Deletes cookies[current_user_token] and set current_user = nil
  def logout_user
  	token = User.new_token
  	current_user.update_attribute(:remember_token, User.hash(token))
  	cookies.delete(:current_user_token)
  	self.current_user = nil
  end

  private

  # Responds. Always includes err_code set to ERROR (SUCCESS by default).
  # Additional response fields can be passed as a hash to ADDITIONAL.
  def respond(error = @@SUCCESS, additional = {})
    response = { err_code: error }.merge(additional)
    respond_to do |format|
      format.html { render json: response, content_type: "application/json" }
      format.json { render json: response, content_type: "application/json" }
    end
  end

  # Checks to see if there is a signed in user
  def signed_in?
  	!current_user.nil?
  end

  # Sets the current_user to a user
  def current_user=(user)
  	@current_user = user
  end

  # Finds the User with the remember_token stored in the session with the key :current_user_token
  # Logging in sets the session value and logging out removes it.
  def current_user
  	token = User.hash(cookies[:current_user_token])
  	@current_user ||= User.find_by(remember_token: token)
  end

end
