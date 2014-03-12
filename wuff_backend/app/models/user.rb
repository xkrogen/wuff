# Class for modeling the user of app
class User < ActiveRecord::Base
	# callback to force email to lowercase for uniqueness
	before_save { self.email = email.downcase }
	# validates the uniqueness of the email address, disregarding lettercase
	validates :email, uniqueness: { case_sensitive: false }
	# method call to return hashed password_digest from password to be stored in db
	#     validation off for empty password and password_confirmation (password_confirmation designed to be done in frontend)
	has_secure_password validations: false

	# Serialize friend_list (array) for easy storage.
	serialize :friend_list, Array
	# Serialize event_list (array) for easy storage.
	serialize :event_list, Array
	# Serialize notification_list (array of hashes) for easy storage.
	serialize :notification_list, Array

  # The maximum length of any user credential field
  MAX_CREDENTIAL_LENGTH = 128
  # The minimum length of password field
  MIN_PW_LENGTH = 6
  # name format only contains letter or whitespace characters
	VALID_NAME_REGEX = /\A[a-zA-z\.']+(\s[a-zA-z\.']+)*\z/
	# email format is [word characters and dashes][@][domain]
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	# Function checks that the user does not exist, the user name, email, and password format is correct
	# * On success the function generates unique_id and remember_token
	# * On success the function adds a row to the DB
	# * On success return code SUCCESS
	# * On failure return an error code (<0): ERR_INVALID_NAME, ERR_INVALID_EMAIL, ERR_EMAIL_TAKEN, ERR_INVALID_PASSWORD
	def add
		return ERR_INVALID_NAME if not name_valid?
		return ERR_INVALID_EMAIL if not email_valid?
		return ERR_INVALID_PASSWORD if not password_valid?
		return ERR_EMAIL_TAKEN if not email_available?
		create_remember_token
		self.friend_list = Array.new
		self.event_list = Array.new
		self.notification_list = Array.new
		self.save
		SUCCESS
	end

	# Function that checks if user :email is in db, then authenticates user: password against db password_digest
	# * On success returns { err_code: SUCCESS, user: db_result }
	# * On failture returns { err_code: ERR_BAD_CREDENTIALS }
	def login
		db_result = self.class.find_by(email: self.email.downcase)
		return { err_code: ERR_BAD_CREDENTIALS } if db_result == nil || !db_result.authenticate(self.password)
		{ err_code: SUCCESS, user: db_result }
	end

	# Finds user Friend via friend_email. If valid, adds Friend.id to self.friend_list and sorts the friend_list.
	# * On success also posts FriendNotification to Friend
	def concat_friend(friend_email)
		friend = self.class.find_by(email: friend_email.downcase)
		return ERR_UNSUCCESSFUL if friend == nil
		if !self.friend_list.include?(friend.id)
			self.friend_list = (self.friend_list << friend.id)
			self.update_attribute(:friend_list, self.friend_list)
			friend.post_notification(FriendNotification.new(self))
		end
		SUCCESS
	end

	# Finds user Friend via friend_email. If valid, delete Friend.id in self.friend_list.
	def remove_friend(friend_email)
		friend = self.class.find_by(email: friend_email.downcase)
		if friend != nil
			self.friend_list.delete(friend.id)
			self.update_attribute(:friend_list, self.friend_list)
		end
		SUCCESS
	end


	# Adds event_id into the user's list of events. Returns 
	# ERR_UNSUCCESSFUL if the event is invalid, SUCCESS otherwise. 
	def add_event(event_id)
		
		# ADD ERROR CHECKING HERE FOR INVALID EVENT -> TEST

		self.event_list |= [event_id]
		self.update_attribute(:event_list, self.event_list)
		
	end

	# Removes event_id from the user's list of events.
	def delete_event(event_id)
		self.event_list.delete(event_id)
		self.update_attribute(:event_list, self.event_list)
		self.notification_list.delete_if do |notif|
			notif.has_key?(:event) && notif[:event] == event_id
		end
	end

	# Changes the user's status (e.g. attending, declined) 
	# within event_id. Does nothing if the event doesn't exist.
	def respond_event(event_id, new_status)
		begin
			event = Event.find(event_id)
		rescue ActiveRecord::RecordNotFound
			return
		end
		event.set_user_status(self.id, new_status)
	end 

	# Adds NOTIFICATION to the user's notification_list. 
	def post_notification(notification)
		self.notification_list = self.notification_list << notification.get_hash
		self.update_attribute(:notification_list, self.notification_list)
	end

	# Function that generates a unique remember_token, random string of base 64
	def self.new_token
		token = loop do
			random_token = SecureRandom.urlsafe_base64
			break random_token unless User.exists?(remember_token: User.hash(random_token))
		end
		token
	end

	# Function that hashes the random token
	# * Param: token 
	def self.hash(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	private

	# Function that generates a hashed session token for user
	def create_remember_token
		self.remember_token = self.class.hash(User.new_token)
	end

  # Function that checks if name is formatted correctly
  # * Return true if name matches VALID_NAME_REGEX, name exists, length non-empty and less than MAX_CREDENTIAL_LENGTH
	def name_valid?
		if self.name == nil
			return false
		elsif VALID_NAME_REGEX !~ self.name || self.name.empty? || self.name.length > MAX_CREDENTIAL_LENGTH
			return false
		end
		true
	end
				
	# Function that checks if email is formatted correctly
	# * Return true if email matches VALID_EMAIL_REGEX, email exists, length non-empty and less than MAX_CREDENTIAL_LENGTH
	def email_valid?
		if self.email == nil
			return false
		elsif VALID_EMAIL_REGEX !~ self.email || self.email.empty? || self.email.length > MAX_CREDENTIAL_LENGTH
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
		if self.password == nil
			return false
		elsif self.password.length < MIN_PW_LENGTH || self.password.length > MAX_CREDENTIAL_LENGTH
			return false
		end
		true
	end

	# Function that generates a new unique_id that is not associated with user in db yet
	# NOT USED in Iteration V1
	def create_unique_id
		self.unique_id = loop do
			random_token = SecureRandom.urlsafe_base64
			break random_token unless User.exists?(unique_id: random_token)
		end
	end
end
