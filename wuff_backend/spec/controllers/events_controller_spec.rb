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
					title: "Test Event", time: DateTime.current.to_i + 10}
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
					title: "Test Event", time: DateTime.current.to_i + 10}

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
					title: "Test Event", time: DateTime.current.to_i} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - invalid user_list 1" do
				before { post 'create_event', { format: 'json', 
					title: "Test Event", time: DateTime.current.to_i,
					user_list: "userid"} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - invalid user_list 2" do
				before { post 'create_event', { format: 'json', 
					title: "Test Event", time: DateTime.current.to_i,
					user_list: "#{@user.email},userid"} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - missing time" do
				before { post 'create_event', { format: 'json', 
					title: "Test Event", user_list: @user.email } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_TIME }
			end
			describe " - time in the past" do
				before { post 'create_event', { format: 'json', time: DateTime.current.to_i - 50, title: "Test Event", user_list: @user.email} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_TIME }
			end
		end
	end

	describe "when inviting new users (event/invite_users)" do

		before do
			@admin = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@admin.add
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

	describe "when updating an existing user's status" do
		before do
			@admin = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@admin.add
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
		end

		it "should fail if the user isn't signed in" do
			@request.cookies['current_user_token'] = 'aBdsfg135_123'
			post 'update_user_status', { format: 'json', event: @event_id,
				status: STATUS_NOT_ATTENDING }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_SESSION
		end

		it "should fail if the event ID isn't valid" do
			@request.cookies['current_user_token'] = @admin_token
			post 'update_user_status', { format: 'json', event: 234525731,
				status: STATUS_NOT_ATTENDING }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD
		end

		it "should change the admin's status" do
			@request.cookies['current_user_token'] = @admin_token
			post 'update_user_status', { format: 'json', event: @event_id,
				status: STATUS_NOT_ATTENDING }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@event.reload
			@event.get_user_status(@admin.id).should eq STATUS_NOT_ATTENDING
			@event.get_user_status(@other.id).should eq STATUS_NO_RESPONSE
		end

		it "should change the other user's status" do
			@request.cookies['current_user_token'] = @other_token
			post 'update_user_status', { format: 'json', event: @event_id,
				status: STATUS_ATTENDING }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@event.reload
			@event.get_user_status(@other.id).should eq STATUS_ATTENDING
			@event.get_user_status(@admin.id).should eq STATUS_ATTENDING
		end
	end

	describe "when viewing an event (event/view)" do
		before do
			@admin = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@admin.add
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@event_id = Event.add_event("Test Event", @admin.id, DateTime.current.to_i + 10, [@admin.id, @other.id], "Testing Event", "A Test Facility")
			@event = Event.find(@event_id)
			@admin_token = User.new_token
			@admin.reload
			@other.reload
			@admin.update_attribute(:remember_token, User.hash(@admin_token))
		end

		it "should fail if the user isn't signed in" do
			@request.cookies['current_user_token'] = 'aBdsfg135_123'
			post 'view', { format: 'json', event: @event_id }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_SESSION
		end

		it "should fail if the event ID isn't valid" do
			@request.cookies['current_user_token'] = @admin_token
			post 'view', { format: 'json', event: 234525731 }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD
		end

		it "should return the correct fields" do
			@request.cookies['current_user_token'] = @admin_token
			post 'view', { format: 'json', event: @event_id }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			JSON.parse(response.body)['event'].should eq @event_id
			JSON.parse(response.body)['title'].should eq "Test Event"
			JSON.parse(response.body)['creator'].should eq @admin.id
			JSON.parse(response.body)['time'].should eq @event.time
			JSON.parse(response.body)['location'].should eq "A Test Facility"
			JSON.parse(response.body)['users']['user_count'].should eq 2
			JSON.parse(response.body)['description'].should eq "Testing Event"
		end
	end

	describe "when removing a user (event/remove_user)" do
		before do
			@admin = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@admin.add
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@event_id = Event.add_event("Test Event", @admin.id, DateTime.current.to_i + 10, [@admin.id, @other.id], "Testing Event", "A Test Facility")
			@event = Event.find(@event_id)
			@admin_token = User.new_token
			@admin.reload
			@other.reload
			@admin.update_attribute(:remember_token, User.hash(@admin_token))
		end

		it "should do nothing if the admin removes himself" do
			@request.cookies['current_user_token'] = @admin_token
			delete 'remove_user', { format: 'json', event: @event_id, 
				user_remove: @admin.email }
			@admin.reload
			@event.reload
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD
			@admin.event_list.should include(@event_id)
			@event.get_user_status(@admin.id).should eq STATUS_ATTENDING
		end

		it "should do nothing if attempting to remove a user not in the event" do
			new_user = User.new(name: "Test Other", email: "test99@example.com",
				password: "test_password")
			new_user.add
			@request.cookies['current_user_token'] = @admin_token
			delete 'remove_user', { format: 'json', event: @event_id, 
				user_remove: new_user.email }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@admin.reload
			@event.reload
			@other.reload
			@event.get_user_status(@admin.id).should eq STATUS_ATTENDING
			@event.get_user_status(@other.id).should eq STATUS_NO_RESPONSE
		end

		it "should properly remove a valid user" do
			@request.cookies['current_user_token'] = @admin_token
			delete 'remove_user', { format: 'json', event: @event_id, 
				user_remove: @other.email }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@admin.reload
			@event.reload
			@other.reload
			@admin.event_list.should include(@event_id)
			@event.get_user_status(@admin.id).should eq STATUS_ATTENDING

			@event.get_user_status(@other.id).should eq nil
			@other.event_list.should_not include(@event_id)
		end
	end

	describe "when cancelling an event (event/cancel_event)" do
		before do
			@admin = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@admin.add
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@event_id = Event.add_event("Test Event", @admin.id, DateTime.current.to_i + 10, [@admin.id, @other.id], "Testing Event", "A Test Facility")
			@event = Event.find(@event_id)
			@admin_token = User.new_token
			@other_token = User.new_token
			@admin.reload
			@other.reload
			@admin.update_attribute(:remember_token, User.hash(@admin_token))
			@other.update_attribute(:remember_token, User.hash(@other_token))
		end

		it "should do nothing if a nonadmin cancels it" do
			@request.cookies['current_user_token'] = @other_token
			delete 'cancel_event', { format: 'json', event: @event_id }
			@admin.reload
			@event.reload
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_PERMISSIONS
			@admin.event_list.should include(@event_id)
			@event.get_user_status(@admin.id).should eq STATUS_ATTENDING
			@other.event_list.should include(@event_id)
			@event.get_user_status(@other.id).should eq STATUS_NO_RESPONSE
		end

		it "should properly cancel a valid event" do
			@request.cookies['current_user_token'] = @admin_token
			delete 'cancel_event', { format: 'json', event: @event_id }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@admin.reload
			@other.reload
			@admin.event_list.should_not include(@event_id)
			@other.event_list.should_not include(@event_id)
			expect { Event.find(@event_id) }.to raise_error(ActiveRecord::RecordNotFound)
		end
	end

	describe "when editing an event (event/edit_event)" do
		before do
			@admin = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@admin.add
			@admin_token = User.new_token
			@admin.update_attribute(:remember_token, User.hash(@admin_token))
			@request.cookies['current_user_token'] = @admin_token
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@other_token = User.new_token
			@other.update_attribute(:remember_token, User.hash(@other_token))
			@event_id = Event.add_event("Test Event", @admin.id, DateTime.current.to_i + 10, [@admin.id, @other.id])
			@admin.reload
			@other.reload
			@event = Event.find(@event_id)
		end

		it "should update the fields if they are all filled out and valid" do
			time = DateTime.current.to_i + 10000
			post 'edit_event', { format: 'json', event: @event_id, 
				title: 'New Test Title', time: time, 
				description: 'New testing description', 
				location: 'A new testing facility' }
			@event.reload
			@event.name.should eq 'New Test Title'
			@event.description.should eq 'New testing description'
			@event.location.should eq 'A new testing facility'
			@event.time.should eq time
		end

		it "should update the filled fields if some are ommitted" do
			time = DateTime.current.to_i + 10000
			post 'edit_event', { format: 'json', event: @event_id,
				location: 'A new testing facility', time: time }
			@event.reload
			@event.name.should eq 'Test Event'
			@event.description.should eq ''
			@event.location.should eq 'A new testing facility'
			@event.time.should eq time
		end

		it "should fail if not an admin" do
			@request.cookies['current_user_token'] = @other_token
			post 'edit_event', { format: 'json', event: @event_id, 
				title: 'New Test Title', 
				description: 'New testing description', 
				location: 'A new testing facility' }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_PERMISSIONS
			@event.reload
			@event.name.should eq 'Test Event'
			@event.description.should eq ''
			@event.location.should eq ''
		end

		describe "with invalid inputs" do
			describe " - name too long" do
				before { post 'edit_event', { format: 'json', event: @event_id,
					title: 'a' * 60 } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_NAME }
			end
			describe " - blank name" do
				before { post 'edit_event', { format: 'json', event: @event_id,
					title: '' } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_NAME }
			end
			describe " - blank time" do
				before { post 'edit_event', { format: 'json', event: @event_id,
					time: '' } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_TIME }
			end
			describe " - time in the past" do
				before { post 'edit_event', { format: 'json', event: @event_id,
					time: DateTime.current.to_i - 50 } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_TIME }
			end
		end
	end
end