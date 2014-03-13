require 'spec_helper'

describe UsersController do

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
					JSON.parse(response.body)['1']['name'].should eq "Test Event"
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
					JSON.parse(response.body)['1']['name'].should eq "Test Event"
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
					event_names = [ JSON.parse(response.body)['1']['name'], 
						JSON.parse(response.body)['2']['name'] ]
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
					event_names = [ JSON.parse(response.body)['1']['name'], 
						JSON.parse(response.body)['2']['name'], 
						JSON.parse(response.body)['3']['name'] ]
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
					JSON.parse(response.body)['1']['name'].should eq "Test Event #1"
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
					event_names = [ JSON.parse(response.body)['1']['name'], 
						JSON.parse(response.body)['2']['name'] ]
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