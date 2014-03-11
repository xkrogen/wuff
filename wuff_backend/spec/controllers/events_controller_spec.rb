require 'spec_helper'
require 'json'

describe EventsController do
	
	describe "when creating an event" do
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
					user_list: "#{@user.id},#{@other.id}",
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
				post 'create_event', { format: 'json', user_list: @user.id.to_s,
					name: "Test Event", time: DateTime.current.to_i + 10}

				response.status.should eq 200
				JSON.parse(response.body)['err_code'].should eq ERR_INVALID_SESSION
				Event.find_by(name: "Test Event").should eq nil
			end
		end

		describe "with invalid/missing inputs" do
			describe " - missing name" do
				before { post 'create_event', { format: 'json', 
					user_list: @user.id.to_s, time: DateTime.current.to_i} }
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
					user_list: "#{@user.id},userid"} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - missing time" do
				before { post 'create_event', { format: 'json', 
					name: "Test Event", user_list: @user.id.to_s} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_TIME }
			end
			describe " - time in the past" do
				before { post 'create_event', { format: 'json', time: DateTime.current.to_i - 50, name: "Test Event", user_list: @user.id.to_s} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_TIME }
			end
		end

	end
end