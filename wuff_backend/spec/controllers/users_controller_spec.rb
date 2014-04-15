require 'spec_helper'
require 'json'

describe UsersController do

	describe "add_user" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com", password: "nopassword")
		end

		describe "with valid login credentials" do
			it "should return { err_code: SUCCESS, id: user_id }" do
				post 'add_user', { format: 'json', name: 'Test Name', email: 'test@example.com', password: 'nopassword' }
				JSON.parse(response.body)['err_code'].should eq SUCCESS
				JSON.parse(response.body)['user_id'].should_not eq nil
			end
		end

		describe  "with invalid login credentials" do
			it "should return { err_code: ERR_INVALID_NAME}" do
				post 'add_user', { format: 'json', name: ' Test Name', email: 'test@example.com', password: 'nopassword' }
				JSON.parse(response.body)['err_code'].should eq ERR_INVALID_NAME
				JSON.parse(response.body)['user_id'].should eq nil
			end

			it "should return { err_code: ERR_EMAIL_TAKEN}" do
				User.new(name: 'Dummy', email: 'test@example.com', password: 'password').add
				post 'add_user', { format: 'json', name: 'Test Name', email: 'test@example.com', password: 'nopassword' }
				JSON.parse(response.body)['err_code'].should eq ERR_EMAIL_TAKEN
				JSON.parse(response.body)['user_id'].should eq nil
			end
		end
	end

	describe "login_user, logout_user" do
		before do
			@user = User.new(name: 'Test Name', email: 'test@example.com', password: 'nopassword')
			@user.add
		end

		describe "login with proper credentials" do
			it "should return SUCCESS, and change remember_token of user" do
				old_token = @user.remember_token
				post 'login_user', { format: 'json', email: 'test@example.com', password: 'nopassword' }
				JSON.parse(response.body)['err_code'].should eq SUCCESS
				JSON.parse(response.body)['user_id'].should eq @user.id
				JSON.parse(response.body)['name'].should eq @user.name
				JSON.parse(response.body)['email'].should eq @user.email
				@user.reload
				@user.remember_token.should_not eq old_token
			end
		end

		describe "login with improper credentials" do
			it "should return ERR_BAD_CREDENTIALS, and change remember_token of user" do
				post 'login_user', { format: 'json', email: 'test@example.com', password: 'yespassword' }
				JSON.parse(response.body)['err_code'].should eq ERR_BAD_CREDENTIALS
			end
		end

		describe "logout user" do
			it "should reset remember_token = nil" do
				@user_token = User.new_token
				@user.update_attribute(:remember_token, User.hash(@user_token))
				@request.cookies['current_user_token'] =  @user_token
				delete 'logout_user'
				@user.reload
				@user.remember_token.should_not eq User.hash(@user_token)
			end
		end
	end

	describe "auth_facebook" do
		before do
			# token may need to be refreshed with FB Graph API Explorer
			@token = 'CAACEdEose0cBAPhaOpQCVB9vC4bOH4utYqgXzclY7S3yC8FrIr3NlmlocThWpMpzTVAuSbZCF5q22cT1XzPmEELEQ6x3nyo6ftq3trZCN2Y7ZC3eO4n4HZCbOQCextyAM53VqCivd9vGnruZCTZCD9AYgwBgXG9fRr0sSHxv68b6Wndc7RYFVmc7mf3DsWCcw7ScAZCOUX1swZDZD'
		end

		describe "authenticate w/o token" do
			it "should return ERR_BAD_CREDENTIALS" do
				post 'auth_facebook', { format: 'json', facebook_id: 'xxxxxxxxxx', facebook_token: '' }
				JSON.parse(response.body)['err_code'].should eq ERR_BAD_CREDENTIALS
			end
		end

		# This test is super sketch, need to get token via FB Graph API Explorer before running test
		describe "autenticate w/ proper token, email not in db" do
			it "should create new user with fb_id in database" do
				User.find_by(email: 'wufftest@gmail.com').should eq nil
				post 'auth_facebook', { format: 'json', facebook_id: '0', facebook_token: @token }
				JSON.parse(response.body)['err_code'].should eq SUCCESS

				User.find_by(email: 'wufftest@gmail.com').should_not eq nil
				User.find_by(fb_id: '0').should_not eq nil

			end
		end
	end

	describe "add_friend, delete_friend" do
		before do
			@user = User.new(name: 'Test Name', email: 'test@example.com', password: 'nopassword')
			@user.add
			@user_token = User.new_token
			@user.update_attribute(:remember_token, User.hash(@user_token))
			@other = User.new(name: "Test Other", email: "t_other@example.com",
					password: "test_password")
			@other.add
			@other_token = User.new_token
			@other.update_attribute(:remember_token, User.hash(@other_token))
			@request.cookies['current_user_token'] =  @user_token 
		end

		describe "add_friend with valid friend user" do
			it "successfully calls User#concat_friend, which is unit tested" do
				post 'add_friend', { format: 'json', friend_email: 't_other@example.com' }
				JSON.parse(response.body)['err_code'].should eq SUCCESS
			end
		end

		describe "add_friend with invalid friend user" do
			it "err_code = ERR_UNSUCCESSFUL" do
				post 'add_friend', { format: 'json', friend_email: 'tttt_other@example.com' }
				JSON.parse(response.body)['err_code'].should eq ERR_UNSUCCESSFUL
			end
		end

		describe "delete_friend deletes user correlated with friend_email if user exists, else nothing happens" do
			it "successfully calls User#remobe_friend, which is unit tested" do
				delete 'delete_friend', { format: 'json', friend_email: 't_other@example,com' }
				JSON.parse(response.body)['err_code'].should eq SUCCESS
			end
		end
	end

	describe "has_notifications, get_notifications, clear_notifications" do
		before do
			@user = User.new(name: 'Test Name', email: 'test@example.com', password: 'nopassword')
			@user.add
			@user_token = User.new_token
			@user.update_attribute(:remember_token, User.hash(@user_token))
			@other = User.new(name: "Test Other", email: "t_other@example.com",
					password: "test_password")
			@other.add
			@other_token = User.new_token
			@other.update_attribute(:remember_token, User.hash(@other_token))
			@request.cookies['current_user_token'] =  @user_token
		end

		describe "has_notifications returns bool" do
			it "returns false when notif list empty" do
				get 'has_notifications?'
				JSON.parse(response.body)['notif'].should eq false
			end

			it "returns true when notif list not 0" do
				@user.post_notification(FriendNotification.new(@other))
				get 'has_notifications?'
				JSON.parse(response.body)['notif'].should eq true

				
			end
		end

		describe "get_notifications returns JSON dictionary of count of notif and each key(notif) = count #" do
			it "returns 0 count" do
				get 'get_notifications'
				JSON.parse(response.body)['notif_count'].should eq 0
			end

			it "returns 1 count after adding one notification and response[1] != nil" do
				@user.post_notification(FriendNotification.new(@other))
				get 'get_notifications'
				JSON.parse(response.body)['notif_count'].should eq 1
				JSON.parse(response.body)['1'].should_not eq nil
			end
		end

		describe "clear_notifications returns SUCCESS and clears notification_list" do
				it "returns SUCCESS" do
				@user.post_notification(FriendNotification.new(@other))
				delete 'clear_notifications'
				@user.reload
				@user.notification_list.size.should eq 0
			end
		end

	end

	describe "get_events" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@user_token = User.new_token
			@user.update_attribute(:remember_token, User.hash(@user_token))
			@other = User.new(name: "Test Other", email: "t_other@example.com",
					password: "test_password")
			@other.add
			@other_token = User.new_token
			@other.update_attribute(:remember_token, User.hash(@other_token))
		end

		describe "with a single event" do
			before do
				@event_id = Event.add_event("Test Event", @user.id, 
					DateTime.current.to_i + 10, [@user.id, @other.id] )
				@user.reload
				@other.reload
			end
			describe "for the event creator" do
				before do
					@request.cookies['current_user_token'] =  @user_token 
					get 'get_events'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "should appear with proper fields" do
					JSON.parse(response.body)['event_count'].should eq 1
					JSON.parse(response.body)['1']['event'].should eq @event_id
					JSON.parse(response.body)['1']['title'].should eq "Test Event"
					users = JSON.parse(response.body)['1']['users']
					user_count = users['user_count']
					user_count.should eq 2
					# Possible refactoring here
					user_names = []
					user_email = []
					user_status = []
					for i in 1..user_count
						user_names <<= users[i.to_s]['name']
						user_email <<= users[i.to_s]['email']
						user_status <<= users[i.to_s]['status']
					end
					user_names.should include("Test Name")
					user_names.should include("Test Other")
					user_email.should include("t_other@example.com")
					user_email.should include("test@example.com")
					user_status.should include(STATUS_ATTENDING)
					user_status.should include(STATUS_NO_RESPONSE)
				end				
			end
			describe "for the event invitee" do
				before do
					@request.cookies['current_user_token'] =  @other_token 
					get 'get_events'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "should appear with proper fields" do
					JSON.parse(response.body)['event_count'].should eq 1
					JSON.parse(response.body)['1']['event'].should eq @event_id
					JSON.parse(response.body)['1']['title'].should eq "Test Event"
				end				
			end
		end

		describe "with multiple events" do
			before do
				@event1_id = Event.add_event("Test Event #1", @user.id, 
					DateTime.current.to_i + 10, [@user.id, @other.id] )
				@event2_id = Event.add_event("Test Event #2", @other.id, 
					DateTime.current.to_i + 105, [@other.id, @user.id] )
				@event3_id = Event.add_event("Test Event #3", @other.id, 
					DateTime.current.to_i + 990, [@other.id] )
				@user.reload
				@other.reload
			end
			describe "for the first user" do
				before do
					@request.cookies['current_user_token'] =  @user_token 
					get 'get_events'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "should appear with proper fields" do
					JSON.parse(response.body)['event_count'].should eq 2
					event_ids = [ JSON.parse(response.body)['1']['event'],
						JSON.parse(response.body)['2']['event'] ]
					event_ids.should include(@event1_id)
					event_ids.should include(@event2_id)
					event_names = [ JSON.parse(response.body)['1']['title'], 
						JSON.parse(response.body)['2']['title'] ]
					event_names.should include("Test Event #1")	
					event_names.should include("Test Event #2")
				end				
			end
			describe "for the event invitee" do
				before do
					@request.cookies['current_user_token'] =  @other_token 
					get 'get_events'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "should appear with proper fields" do
					JSON.parse(response.body)['event_count'].should eq 3
					event_ids = [ JSON.parse(response.body)['1']['event'],
						JSON.parse(response.body)['2']['event'], 
						JSON.parse(response.body)['3']['event'] ]
					event_ids.should include(@event1_id)
					event_ids.should include(@event2_id)
					event_ids.should include(@event3_id)
					event_names = [ JSON.parse(response.body)['1']['title'], 
						JSON.parse(response.body)['2']['title'], 
						JSON.parse(response.body)['3']['title'] ]
					event_names.should include("Test Event #1")	
					event_names.should include("Test Event #2")
					event_names.should include("Test Event #3")
				end								
			end
		end

		describe "with invalid events in the user's event_list" do
			before do
				@event1_id = Event.add_event("Test Event #1", @user.id, 
					DateTime.current.to_i + 10, [@user.id, @other.id] )
				@event2_id = Event.add_event("Test Event #2", @other.id, 
					DateTime.current.to_i + 990, [@other.id] )
				@user.reload
				@user.update_attribute(:event_list, @user.event_list << @event3_id)
				@user.reload
				@other.reload
			end
			describe "for the first user" do
				before do
					@request.cookies['current_user_token'] =  @user_token 
					get 'get_events'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "valid events should appear with proper fields" do
					JSON.parse(response.body)['event_count'].should eq 1
					JSON.parse(response.body)['1']['event'].should eq @event1_id
					JSON.parse(response.body)['1']['title'].should eq "Test Event #1"
				end				
				it "invalid events should be removed from event_list" do
					@user.reload
					@user.event_list.should have(1).items
				end
			end
			describe "for the other user" do
				before do
					@request.cookies['current_user_token'] =  @other_token 
					get 'get_events'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "valid events should appear with proper fields" do
					JSON.parse(response.body)['event_count'].should eq 2
					event_ids = [ JSON.parse(response.body)['1']['event'],
						JSON.parse(response.body)['2']['event'] ]
					event_ids.should include(@event1_id)
					event_ids.should include(@event2_id)
					event_names = [ JSON.parse(response.body)['1']['title'], 
						JSON.parse(response.body)['2']['title'] ]
					event_names.should include("Test Event #1")	
					event_names.should include("Test Event #2")
				end				
				it "invalid events should be removed from event_list" do
					@other.reload
					@other.event_list.should have(2).items
				end
			end
		end
	end

end