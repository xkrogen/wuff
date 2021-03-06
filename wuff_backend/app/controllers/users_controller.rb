include RestGraph::RailsUtil

class UsersController < ApplicationController

  # Session ID does not match this user.remember_token
  ERR_INVALID_SESSION = -11

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
      @user.add_device_token(params['device_token']) if params.has_key?('device_token')
  		cookies.permanent[:current_user_token] = token
  		@user.update_attribute(:remember_token, User.hash(token))
  		current_user = @user
      respond(rval, { user_id: current_user.id,  email: current_user.email, name: current_user.name })
      Event.add_event("Welcome to WUFF", current_user.id, 
        DateTime.now.to_i + 2*60*60, [current_user.id], "", "WUFF Community")
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
  		@user.update_attribute(:remember_token, User.hash(token))
  		current_user = @user
      current_user.add_device_token(params['device_token']) if params.has_key?('device_token')
      respond(rval[:err_code], { user_id: current_user.id, email: current_user.email, name: current_user.name })
  	end
  end

  # POST /user/auth_facebook
  def auth_facebook
    @user = User.find_by(fb_id: params[:facebook_id])
    if @user == nil
      begin
        rest_graph_setup
        rg = RestGraph.new(:access_token => params[:facebook_token])
        medata = rg.get('me')
        @user = User.find_by(email: medata['email'])
        if @user == nil
          @user = User.new(name: medata['name'], email:  medata['email'], password: SecureRandom.urlsafe_base64)
          @user.add
          Event.add_event("Welcome to WUFF", @user.id, 
            DateTime.now.to_i + 2*60*60, [@user.id], "", "WUFF Community")
        end
      rescue => exception
        respond(ERR_BAD_CREDENTIALS)
        return
      end
    end
    token = User.new_token
    cookies.permanent[:current_user_token] = token
    @user.update_attribute(:remember_token, User.hash(token))
    @user.update_attribute(:fb_id, params[:facebook_id])
    @user.update_attribute(:fb_token, params[:facebook_token])
    current_user = @user
    respond(SUCCESS, { user_id: current_user.id, email: current_user.email, name: current_user.name })
  end

  # Returns information about every Facebook friend of the currently 
  # logged in user. If the currently logged in user is not a Facebook user, returns 0 users. Each user is { $name: user_name, $fb_id: user_facebook_id }
  # Return { $count: user_count, 1: user_1, 2: user_2, … }
  def get_facebook_friends
    if not signed_in?
      session_fail_response
      return
    end
    if not is_facebook_user?
      respond(SUCCESS, { count: 0 })
      return
    end

    fb_id = @current_user.fb_id
    fb_token = @current_user.fb_token
    if fb_token == nil
      respond(ERR_UNSUCCESSFUL)
      return
    end
    rest_graph = RestGraph.new(:access_token => fb_token)
    friend_list = rest_graph.get('me/friends')['data']
    friend_count = 0
    output_hash = {}
    friend_list.each do |friend_hash|
      friend_count += 1
      output_hash[friend_count] = friend_hash
    end
    output_hash[:count] = friend_count
    respond(SUCCESS, output_hash)
  end

  # Returns information about every Facebook friend of the currently 
  # logged in user. If the currently logged in user is not a Facebook user, returns 0 users. Each user is { $name: user_name, $fb_id: user_facebook_id }
  # Return { $count: user_count, 1: user_1, 2: user_2, … }
  def get_facebook_friends
    if not signed_in?
      session_fail_response
      return
    end
    if not is_facebook_user?
      respond(SUCCESS, { count: 0 })
      return
    end

    fb_id = @current_user.fb_id
    fb_token = @current_user.fb_token
    if fb_token == nil
      respond(ERR_UNSUCCESSFUL)
      return
    end
    rest_graph = RestGraph.new(:access_token => fb_token)
    friend_list = rest_graph.get('me/friends')['data']
    friend_count = 0
    output_hash = {}
    friend_list.each do |friend_hash|
      friend_count += 1
      output_hash[friend_count] = friend_hash
    end
    output_hash[:count] = friend_count
    respond(SUCCESS, output_hash)
  end

  # POST /user/get_profile_pic
  # Supports retrival of profile picture via Facebook Graph
  # ERR_UNSUCCESFUL if email not valid, or corresponding user does not have facebook credentials
  # returns url to picture
  def get_profile_pic
    @user = User.find_by(email: params[:email])
    @user = User.find_by(id: params[:user_id]) if @user == nil
    if @user == nil || @user.fb_id == nil
      respond(ERR_UNSUCCESSFUL)
      return
    end
    begin
      rest_graph_setup
      rg = RestGraph.new()
      medata = rg.get("#{@user.fb_id}/?fields=picture&type=square")
      respond(SUCCESS, { pic_url: medata['picture']['data']['url'] })
    rescue => exception
      respond(ERR_UNSUCCESFUL)
      return
    end
  end

  # GET /user/get_all_users
  # Return a list of all users signed up for Wuff
  # (Used for autocompletion purposes)
  def get_all_users
    user_count = 0
    user_list = {}
    User.all.each do |user|
      user_count += 1
      user_list[user_count] = user.get_hash
    end
    user_list[:count] = user_count
    respond(SUCCESS, user_list)
  end

  # DELETE /user/logout_user
  # Logout the current_user
  # * Changes current_user's remember_token in database
  # * Deletes cookies[current_user_token] and set current_user = nil
  def logout_user
    if !current_user.nil?
  	 token = User.new_token
  	 current_user.update_attribute(:remember_token, User.hash(token))
  	 cookies.delete(:current_user_token)
     current_user.remove_device_token(params['device_token']) if params.has_key?('device_token')
  	 current_user = nil
    end
    respond(SUCCESS)
  end

  # POST /user/add_friend
  # Calls current_user.concat_friend
  def add_friend
    if not signed_in?
      session_fail_response
      return
    end
    rval = current_user.concat_friend(params[:friend_email])
    respond(rval)
  end

  # POST /user/delete_friend
  # Calls current_user.remove_friend
  def delete_friend
    if not signed_in?
      session_fail_response
      return
    end
    rval = current_user.remove_friend(params[:friend_email])
    respond(rval)
  end

  # GET /user/get_events
  # Returns all of the relevant information to display user_id’s events 
  # on their main screen. Nested JSON for each event.  
  #
  # If invalid event IDs are found, automatically removes them from
  # the user's event list. 
  def get_events
    if not signed_in?
      session_fail_response
      return
    end
    return_list = {}
    event_count = 0
    user = current_user
    event_list_size_old = user.event_list.size
    user.event_list.delete_if do |event_id|
      begin
        event = Event.find(event_id)
      rescue ActiveRecord::RecordNotFound
        next true
      end
      event_count += 1
      return_list[event_count] = event.get_hash
      false
    end
    user.update_attribute(:event_list, user.event_list) if event_list_size_old != user.event_list.size
    return_list[:event_count] = event_count
    respond(SUCCESS, return_list)
  end


  # GET /user/get_groups
  # Returns all of the relevant information to display user_id’s groups. 
  # Nested JSON for each group. 
  #
  # If invalid group IDs are found, automatically removes them from
  # the user's group list. 
  def get_groups
    if not signed_in?
      session_fail_response
      return
    end
    return_list = {}
    group_count = 0
    user = current_user
    group_list_size_old = user.group_list.size
    user.group_list.delete_if do |group_id|
      begin
        group = Group.find(group_id)
      rescue ActiveRecord::RecordNotFound
        next true
      end
      group_count += 1
      return_list[group_count] = group.get_hash
      false
    end
    user.update_attribute(:group_list, user.group_list) if group_list_size_old != user.group_list.size
    return_list[:group_count] = group_count
    respond(SUCCESS, return_list)
  end

  # GET /user/get_friends
  # Returns all of the relevant information to display user_id’s friends. 
  # Nested JSON for each friend. 
  #
  # If invalid friend IDs are found, automatically removes them from
  # the user's friend list. 
  def get_friends
    if not signed_in?
      session_fail_response
      return
    end
    return_list = {}
    friend_count = 0
    user = current_user
    friend_list_size_old = user.friend_list.size
    user.friend_list.delete_if do |friend_id|
      begin
        friend = User.find(friend_id)
      rescue ActiveRecord::RecordNotFound
        next true
      end
      friend_count += 1
      return_list[friend_count] = friend.get_hash
      false
    end
    user.update_attribute(:friend_list, user.friend_list) if friend_list_size_old != user.friend_list.size
    return_list[:friend_count] = friend_count
    respond(SUCCESS, return_list)
  end

  # GET /user/has_notifications
  # Check if the user.notification_list is empty
  # Upon success, format JSON { err_code: code, notif: val }
  def has_notifications?
    if not signed_in?
      session_fail_response
      return
    end
    val = current_user.notification_list.size >= 1
    respond(SUCCESS, { notif: val })
  end

  # GET /user/get_notifications
  # Returns a list of pending notifications as JSON
  def get_notifications
    if not signed_in?
      session_fail_response
      return
    end
    return_list = {}
    notif_count = 0
    current_user.notification_list.each do |notif|
      notif_count += 1
      return_list[notif_count] = notif
    end
    return_list[:notif_count] = notif_count
    respond(SUCCESS, return_list)
  end

  # DELETE /user/clear_notifications
  # Upon Success, the current_user.notification_list is empty
  def clear_notifications
    if not signed_in?
      session_fail_response
      returns
    end
    current_user.update_attribute(:notification_list, Array.new)
    respond(SUCCESS)
  end

  private

  # Responds. Always includes err_code set to ERROR (SUCCESS by default).
  # Additional response fields can be passed as a hash to ADDITIONAL.
  def respond(error = SUCCESS, additional = {})
    response = { err_code: error }.merge(additional)
    respond_to do |format|
      format.html { render json: response, content_type: "application/json" }
      format.json { render json: response, content_type: "application/json" }
    end
  end

  def session_fail_response
    response = { err_code: ERR_INVALID_SESSION }
    respond_to do |format|
      format.html { render json: response, content_type: "application/json" }
      format.json { render json: response, content_type: "application/json" }
    end
  end

  # Checks to see if the current user is a Facebook user
  def is_facebook_user?
    @current_user.fb_id != nil 
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
