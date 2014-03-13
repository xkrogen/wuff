require 'spec_helper'
require 'json'

describe EventsController do
	
	describe "when creating an event (event/create_event)" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@token = User.new_token
			@user.update_attribute(:remember_token, User.hash(@token))
			@request.cookies['current_user_token'] = @token
		end

		describe "with valid inputs" do
			before do
				@other = User.new(name: "Test Other", email: "t_other@example.com",
					password: "test_password")
				@other.add
				post 'create_event', { format: 'json', 
					user_list: "#{@user.email},#{@other.email}",
					name: "Test Event", time: DateTime.current.to_i + 10}
				@user.reload
				@other.reload
				@event_id = JSON.parse(response.body)['event']
			end

			specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }

			describe "the event_list of the users involved" do
				specify { @user.event_list.should include(@event_id) }
				specify { @other.event_list.should include(@event_id) }
			end
		end

		describe "while not logged in" do
			before { @request.cookies['current_user_token'] = 'invalid token' }

			it "should return err_code of ERR_INVALID_SESSION" do
				post 'create_event', { format: 'json', user_list: @user.email,
					name: "Test Event", time: DateTime.current.to_i + 10}

				response.status.should eq 200
				JSON.parse(response.body)['err_code'].should eq ERR_INVALID_SESSION
				Event.find_by(name: "Test Event").should eq nil
			end
		end

		describe "with invalid/missing inputs" do
			describe " - missing name" do
				before { post 'create_event', { format: 'json', 
					user_list: @user.email, time: DateTime.current.to_i} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_NAME }
			end
			describe " - missing user_list" do
				before { post 'create_event', { format: 'json', 
					name: "Test Event", time: DateTime.current.to_i} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - invalid user_list 1" do
				before { post 'create_event', { format: 'json', 
					name: "Test Event", time: DateTime.current.to_i,
					user_list: "userid"} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - invalid user_list 2" do
				before { post 'create_event', { format: 'json', 
					name: "Test Event", time: DateTime.current.to_i,
					user_list: "#{@user.email},userid"} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - missing time" do
				before { post 'create_event', { format: 'json', 
					name: "Test Event", user_list: @user.email } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_TIME }
			end
			describe " - time in the past" do
				before { post 'create_event', { format: 'json', time: DateTime.current.to_i - 50, name: "Test Event", user_list: @user.email} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_TIME }
			end
		end
	end

	describe "when inviting new users (event/invite_users)" do

		before do
			@admin = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@admin.add
			@request.cookies['current_user_token'] = @token
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@event_id = Event.add_event("Test Event", @admin.id, DateTime.current.to_i + 10, [@admin.id, @other.id])
			@event = Event.find(@event_id)
			@admin_token = User.new_token
			@other_token = User.new_token
			@admin.reload
			@other.reload
			@admin.update_attribute(:remember_token, User.hash(@admin_token))
			@other.update_attribute(:remember_token, User.hash(@other_token))
			@new_user1 = User.new(name: "Friend One", email: "friend1@example.com",
				password: "test_password")
			@new_user1.add
			@new_user2 = User.new(name: "Friend Two", email: "friend2@example.com",
				password: "test_password")
			@new_user2.add
			@new_user1.reload
			@new_user2.reload
		end

		describe "when adding as admin" do
			before { @request.cookies['current_user_token'] = @admin_token }
			describe "with all valid users" do
				before do
					post 'invite_users', { format: 'json', event: @event_id,
						user_list: "friend1@example.com,friend2@example.com" }
					@admin.reload
					@other.reload
					@new_user1.reload
					@new_user2.reload
				end
				it "should be successful" do
					JSON.parse(response.body)['err_code'].should eq SUCCESS
					@admin.event_list.should include(@event_id)
					@other.event_list.should include(@event_id) 
					@new_user1.event_list.should include(@event_id)
					@new_user2.event_list.should include(@event_id) 
					@new_user1.notification_list.should have(1).items
					@new_user2.notification_list.should have(1).items 
					@admin.notification_list.should have(0).items
					@other.notification_list.should have(1).items 
					@event.reload
					@event.get_user_status(@new_user1.id).should eq STATUS_NO_RESPONSE
					@event.get_user_status(@new_user2.id).should eq STATUS_NO_RESPONSE
				end				 
			end

			describe "with an invalid user" do
				before do
					post 'invite_users', { format: 'json', event: @event_id,
						user_list: "ran_email_bad@example.com,friend2@example.com" }
					@admin.reload
					@other.reload
					@new_user1.reload
					@new_user2.reload
				end
				it "should return an error" do
					JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD
					@admin.event_list.should include(@event_id)
					@other.event_list.should include(@event_id) 
					@new_user1.event_list.should_not include(@event_id)
					@new_user2.event_list.should_not include(@event_id) 
					@new_user1.notification_list.should have(0).items
					@new_user2.notification_list.should have(0).items 
					@admin.notification_list.should have(0).items
					@other.notification_list.should have(1).items 
					@event.reload
					@event.get_user_status(@new_user1.id).should eq nil
					@event.get_user_status(@new_user2.id).should eq nil
				end	
			end

			describe "with a duplicate user" do
				before do
					@event.set_user_status(@other.id, STATUS_ATTENDING)
					post 'invite_users', { format: 'json', event: @event_id,
						user_list: "t_other@example.com,friend2@example.com" }
					@admin.reload
					@other.reload
					@new_user1.reload
					@new_user2.reload
				end
				it "should be successful but ignore duplicate" do
					JSON.parse(response.body)['err_code'].should eq SUCCESS
					@admin.event_list.should include(@event_id)
					@other.event_list.should include(@event_id) 
					@new_user2.event_list.should include(@event_id) 
					@new_user2.notification_list.should have(1).items 
					@admin.notification_list.should have(0).items
					@other.notification_list.should have(1).items 
					@event.reload
					@event.get_user_status(@other.id).should eq STATUS_ATTENDING
					@event.get_user_status(@new_user2.id).should eq STATUS_NO_RESPONSE
				end	
			end
		end

		describe "when adding as a non-admin" do
			before do
				@request.cookies['current_user_token'] = @other_token
				post 'invite_users', { format: 'json', event: @event_id,
					user_list: "friend1@example.com,friend2@example.com" }
				@admin.reload
				@other.reload
				@new_user1.reload
				@new_user2.reload
			end
			it "should fail with an error" do
				JSON.parse(response.body)['err_code'].should eq ERR_INVALID_PERMISSIONS
				@admin.event_list.should include(@event_id)
				@other.event_list.should include(@event_id) 
				@new_user1.event_list.should_not include(@event_id)
				@new_user2.event_list.should_not include(@event_id) 
				@new_user1.notification_list.should have(0).items
				@new_user2.notification_list.should have(0).items 
				@admin.notification_list.should have(0).items
				@other.notification_list.should have(1).items 
				@event.reload
				@event.get_user_status(@new_user1.id).should eq nil
				@event.get_user_status(@new_user2.id).should eq nil
			end	
		end

		describe "when adding to an invalid event" do
			before do
				@request.cookies['current_user_token'] = @admin_token
				post 'invite_users', { format: 'json', event: 93452345,
					user_list: "friend1@example.com,friend2@example.com" }
				@admin.reload
				@other.reload
				@new_user1.reload
				@new_user2.reload
			end
			it "should fail with an error" do
				JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD
				@admin.event_list.should include(@event_id)
				@other.event_list.should include(@event_id) 
				@new_user1.event_list.should_not include(@event_id)
				@new_user2.event_list.should_not include(@event_id) 
				@new_user1.notification_list.should have(0).items
				@new_user2.notification_list.should have(0).items 
				@admin.notification_list.should have(0).items
				@other.notification_list.should have(1).items 
				@event.reload
				@event.get_user_status(@new_user1.id).should eq nil
				@event.get_user_status(@new_user2.id).should eq nil
			end	
		end
	end
end