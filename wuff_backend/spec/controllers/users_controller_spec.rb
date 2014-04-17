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

		describe "login with a device token" do
			it "should have user[device_token] not nil" do
				@user.device_tokens.empty?.should eq true
				post 'login_user', { format: 'json', email: 'test@example.com', password: 'nopassword', device_token: '0000' }
				@user.reload
				@user.device_tokens.empty?.should eq false
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
			@token = 'CAAG3tpE5O1UBAKl31Y80KmStU0azLLZBIgZAjJZCwvAH6EaXNDtXk9hcQVQYbioMNrb3YVsoqmTGENOO4F7zyLwYAr5ZAlJkm47TEWpETS7QZCVR5UpH9DS6eNMESHhhZAmW789KnuqDqz39ZCITQRKkpgfnLPXmSHEuQPqSDbNZCZBpSLzA9O1bxTjS9i2HuvJ9iACygNsGmiNxCeqimZBtyd'
		end

		describe "authenticate w/o token" do
			it "should return ERR_BAD_CREDENTIALS" do
				post 'auth_facebook', { format: 'json', facebook_id: 'xxxxxxxxxx', facebook_token: '' }
				JSON.parse(response.body)['err_code'].should eq ERR_BAD_CREDENTIALS
			end
		end

		describe "autenticate w/ proper token, email not in db" do
			it "should create new user with fb_id in database" do
				User.find_by(email: 'wufftest@gmail.com').should eq nil
				post 'auth_facebook', { format: 'json', facebook_id: '100008122715374', facebook_token: @token }
				JSON.parse(response.body)['err_code'].should eq SUCCESS
				User.find_by(fb_id: '100008122715374').should_not eq nil
			end
		end
	end

	describe "get_profile_pic" do
		before do
			@user = User.new(name: 'Test Name', email: 'test@example.com', password: 'nopassword')
			@user.add
		end

		describe "try to get profile_pic without facebook_id associated with user" do
			it "should return ERR_UNSUCCESSFUL" do
				post 'get_profile_pic', { format: 'json', email: 'test@example.com' }
				JSON.parse(response.body)['err_code'].should eq ERR_UNSUCCESSFUL
			end
		end

		describe "try to get profile_pic given email" do
			it "should return url to profile_pic" do
				@user.update_attribute(:fb_id, '517267866');
				@user.reload
				post 'get_profile_pic', { format: 'json', email: 'test@example.com' }
				JSON.parse(response.body)['err_code'].should eq SUCCESS
				JSON.parse(response.body)['pic_url'].should_not eq nil
			end
		end

		describe "try to get profile_pic given id" do
			it "should return url to profile_pic" do
				@user.update_attribute(:fb_id, '517267866');
				@user.reload
				post 'get_profile_pic', { format: 'json', user_id: @user.id }
				JSON.parse(response.body)['err_code'].should eq SUCCESS
				JSON.parse(response.body)['pic_url'].should_not eq nil
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
			it "successfully calls User#remove_friend, which is unit tested" do
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

	describe "get_groups" do
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

		describe "with a single group" do
			before do
				@group_id = Group.add_group("Test Group", [@user.id, @other.id] )
				@user.reload
				@other.reload
			end
			describe "for the members of the group" do
				before do
					@request.cookies['current_user_token'] =  @user_token 
					get 'get_groups'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "should appear with proper fields" do
					JSON.parse(response.body)['group_count'].should eq 1
					JSON.parse(response.body)['1']['group'].should eq @group_id
					JSON.parse(response.body)['1']['name'].should eq "Test Group"
					users = JSON.parse(response.body)['1']['users']
					user_count = users['user_count']
					user_count.should eq 2
					# Possible refactoring here
					user_names = []
					user_email = []
					for i in 1..user_count
						user_names <<= users[i.to_s]['name']
						user_email <<= users[i.to_s]['email']
					end
					user_names.should include("Test Name")
					user_names.should include("Test Other")
					user_email.should include("t_other@example.com")
					user_email.should include("test@example.com")
				end				
			end
		end

		describe "with multiple groups" do
			before do
				@group1_id = Group.add_group("Test Group #1", [@user.id, @other.id] )
				@group2_id = Group.add_group("Test Group #2", [@other.id, @user.id] )
				@group3_id = Group.add_group("Test Group #3", [@other.id] )
				@user.reload
				@other.reload
			end
			describe "for the first user" do
				before do
					@request.cookies['current_user_token'] =  @user_token 
					get 'get_groups'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "should appear with proper fields" do
					JSON.parse(response.body)['group_count'].should eq 2
					group_ids = [ JSON.parse(response.body)['1']['group'],
						JSON.parse(response.body)['2']['group'] ]
					group_ids.should include(@group1_id)
					group_ids.should include(@group2_id)
					group_names = [ JSON.parse(response.body)['1']['name'], 
						JSON.parse(response.body)['2']['name'] ]
					group_names.should include("Test Group #1")	
					group_names.should include("Test Group #2")
				end				
			end
			describe "for the other user" do
				before do
					@request.cookies['current_user_token'] =  @other_token 
					get 'get_groups'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "should appear with proper fields" do
					JSON.parse(response.body)['group_count'].should eq 3
					group_ids = [ JSON.parse(response.body)['1']['group'],
						JSON.parse(response.body)['2']['group'], 
						JSON.parse(response.body)['3']['group'] ]
					group_ids.should include(@group1_id)
					group_ids.should include(@group2_id)
					group_ids.should include(@group3_id)
					group_names = [ JSON.parse(response.body)['1']['name'], 
						JSON.parse(response.body)['2']['name'],
						JSON.parse(response.body)['3']['name']  ]
					group_names.should include("Test Group #1")	
					group_names.should include("Test Group #2")
					group_names.should include("Test Group #3")
				end								
			end
		end

		describe "with invalid groups in the user's group_list" do
			before do
				@group1_id = Group.add_group("Test Group #1", [@user.id, @other.id] )
				@group2_id = Group.add_group("Test Group #2", [@other.id] )
				@user.reload
				@user.update_attribute(:group_list, @user.group_list << 23452345)
				@user.reload
				@other.reload
			end
			describe "for the first user" do
				before do
					@request.cookies['current_user_token'] =  @user_token 
					get 'get_groups'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "valid groups should appear with proper fields" do
					JSON.parse(response.body)['group_count'].should eq 1
					JSON.parse(response.body)['1']['group'].should eq @group1_id
					JSON.parse(response.body)['1']['name'].should eq "Test Group #1"
				end				
				it "invalid groups should be removed from group_list" do
					@user.reload
					@user.group_list.should have(1).items
				end
			end
		end
	end

	describe "get_friend" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@user_token = User.new_token
			@user.update_attribute(:remember_token, User.hash(@user_token))
		end

		describe "with no friends" do
			before do
				@request.cookies['current_user_token'] =  @user_token 
				get 'get_friends'
			end
			specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
			it "should appear with proper fields" do
				JSON.parse(response.body)['friend_count'].should eq 0
			end			
		end

		describe "with multiple friends" do
			before do
				@other = User.new(name: "Test Other", 
					email: "t_other@example.com", password: "test_password")
				@other.add
				@other2 = User.new(name: "Test Others", 
					email: "t_other2@example.com", password: "test_password")
				@other2.add
				@user.concat_friend("t_other@example.com")
				@user.concat_friend("t_other2@example.com")
				@user.reload
			end
			describe "for the first user" do
				before do
					@request.cookies['current_user_token'] =  @user_token 
					get 'get_friends'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "should appear with proper fields" do
					JSON.parse(response.body)['friend_count'].should eq 2
					friend_names = [ JSON.parse(response.body)['1']['name'], 
						JSON.parse(response.body)['2']['name'] ]
					friend_names.should include("Test Other")	
					friend_names.should include("Test Others")
					friend_emails = [ JSON.parse(response.body)['1']['email'], 
						JSON.parse(response.body)['2']['email'] ]
					friend_emails.should include("t_other@example.com")	
					friend_emails.should include("t_other2@example.com")
				end				
			end
		end

		describe "with invalid friends in the user's friend_list" do
			before do
				@other = User.new(name: "Test Other", email: "t_other@example.com",
						password: "test_password")
				@other.add
				@user.concat_friend("t_other@example.com")
				@user.reload
				@user.update_attribute(:friend_list, @user.friend_list << 345234)
				@user.reload
			end
			describe "for the user" do
				before do
					@request.cookies['current_user_token'] =  @user_token 
					get 'get_friends'
				end
				specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }
				it "valid friends should appear with proper fields" do
					JSON.parse(response.body)['friend_count'].should eq 1
					JSON.parse(response.body)['1']['email'].should eq "t_other@example.com"
					JSON.parse(response.body)['1']['name'].should eq "Test Other"
				end				
				it "invalid groups should be removed from friend_list" do
					@user.reload
					@user.friend_list.should have(1).items
				end
			end
		end
	end

end