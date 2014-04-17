require 'spec_helper'
require 'Condition'
require 'NoCondition'
require 'NumberCondition'
require 'UserCondition' 

NAME_MAX_LENGTH = 40

describe Event, "creation" do
	  
  before do
  	@admin = User.create(name: 'Example User', 
  		email: 'exampleuser@example.com')
  	@admin_id = @admin.id
  	@other = User.create(name: 'Example Friend',
  		email: 'examplefriend@example.com')
  	@other_id = @other.id
	end

	describe "when everything is valid" do
		before do
			@event_id = Event.add_event('Example Event', @admin_id, 
  			DateTime.current.to_i + 10, [@admin_id, @other_id])
			@admin.reload
			@other.reload
		end
		specify { @event_id.should be > 0 }

		describe "the event_list of the users involved" do
			specify { @admin.event_list.should include(@event_id) }
			specify { @other.event_list.should include(@event_id) }
		end

		describe "fields within the event" do
			before { @event = Event.find(@event_id) }
			it "should have all valid fields" do
				@event.party_list[@admin.id][:status].should eq STATUS_ATTENDING
				@event.party_list[@other.id][:status].should eq STATUS_NO_RESPONSE
				@event.party_list[@admin.id][:condition][:cond_type].should eq COND_NONE
				@event.party_list[@other.id][:condition][:cond_type].should eq COND_NONE
			end
		end

		describe "the notification_list of the users involved" do
			specify { @admin.notification_list.size.should eq 0 }
			specify { @other.notification_list.size.should eq 1 }
			specify { @other.notification_list.first[:notif_type].
					should eq NOTIF_NEW_EVENT }
			specify { @other.notification_list.first[:notif_time].should 
				be_within(1).of(DateTime.current.to_i) }
			specify { @other.notification_list.first[:event].should eq @event_id }
			specify { @other.notification_list.first[:name].should eq "Example Event" }
			specify { @other.notification_list.first[:location].should eq "" }
			specify { @other.notification_list.first[:creator][:name].should eq 'Example User' }
			specify { @other.notification_list.first[:creator][:email].should eq 'exampleuser@example.com' }
		end
	end

	describe "when name field" do
		describe "is empty" do
			before { @event_id = Event.add_event('', @admin_id, 
  			DateTime.current.to_i + 10, [@admin_id])}
			specify { @event_id.should eq ERR_INVALID_NAME }
		end
		describe "is too long" do
			before { @event_id = Event.add_event('A' * (NAME_MAX_LENGTH + 1), 
				@admin_id, DateTime.current.to_i + 10, [@admin_id]) }
			specify { @event_id.should eq ERR_INVALID_NAME }
		end
	end

	describe "when admin field is empty" do
		before { @event_id = Event.add_event('Example Event', 0, 
  		DateTime.current.to_i + 10, [@admin_id]) }
		specify { expect(@event_id).to eq(ERR_INVALID_FIELD) }
	end

	describe "when party list" do
		before { @event = Event.new(name: 'Example Name', 
			admin: 1, time: (DateTime.current.to_i + 10), 
			party_list: { 1 => { status: STATUS_ATTENDING } }) }
		describe "is not a hash" do
			before { @event.party_list = '' }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_FIELD) }
		end
		describe "is an empty hash" do
			before { @event.party_list = {} }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_FIELD) }
		end
		describe "does not contain the admin" do
			before { @event.party_list = { 2 => {status: STATUS_ATTENDING} } }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_FIELD) }
		end
		describe "contains the admin and other users" do
			before do
				@event.party_list[2] = {status: STATUS_NOT_ATTENDING}
				@event.party_list[50] = {status: STATUS_NO_RESPONSE }
			end
			specify { expect(@event.is_valid?).to eq(SUCCESS) }
		end
		describe "doesn't contain a status hash for any user" do
			before { @event.party_list = {1 => STATUS_ATTENDING, 2 => STATUS_NOT_ATTENDING} }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_FIELD) }
		end
		describe "doesn't contain status hash for each user" do
			before { @event.party_list[2] = STATUS_NO_RESPONSE }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_FIELD) }
		end
	end

	describe "when list_of_users" do
		describe "is not an array" do
			before { @event_id = Event.add_event('Example Event', @admin_id, 
  			DateTime.current.to_i + 10, '') }
			specify { expect(@event_id).to eq(ERR_INVALID_FIELD) }
		end
		describe "is an empty array" do
			before { @event_id = Event.add_event('Example Event', @admin_id, 
  			DateTime.current.to_i + 10, []) }
			specify { expect(@event_id).to eq(ERR_INVALID_FIELD) }
		end
		describe "does not contain the admin" do
			before { @event_id = Event.add_event('Example Event', @admin_id, 
  			DateTime.current.to_i + 10, [@other_id]) }
			specify { expect(@event_id).to eq(ERR_INVALID_FIELD) }
		end
		describe "contains the admin and other users" do
			before { @event_id = Event.add_event('Example Event', @admin_id, 
  			DateTime.current.to_i + 10, [@admin_id, @other_id]) }
			specify { expect(@event_id).to be > 0 }
		end
	end

	describe "when time" do
		describe "is far in the future" do
			before { @event_id = Event.add_event('Example Event', @admin_id, 
  			DateTime.current.to_i + 1000000, [@admin_id]) }
			specify { expect(@event_id).to be > 0}
		end
		describe "is in the past" do
			before { @event_id = Event.add_event('Example Event', @admin_id, 
  			DateTime.current.to_i - 30, [@admin_id]) }
			specify { expect(@event_id).to eq(ERR_INVALID_TIME) }
		end
		describe "is negative" do
			before { @event_id = Event.add_event('Example Event', 
				@admin_id, -50, [@admin_id]) }
			specify { expect(@event_id).to eq(ERR_INVALID_TIME) }
		end
		describe "is zero" do
			before { @event_id = Event.add_event('Example Event', 
				@admin_id, 0, [@admin_id]) }
			specify { expect(@event_id).to eq(ERR_INVALID_TIME) }
		end
	end
end

describe Event, "misc" do

	describe "#get_user_status, #set_user_status" do
	 	before do
	  	@admin = User.create(name: 'Example User', 
	  		email: 'exampleuser@example.com')
	  	@admin_id = @admin.id
	  	@other = User.create(name: 'Example Friend',
	  		email: 'examplefriend@example.com')
	  	@other_id = @other.id
	  	@event_id = Event.add_event('Example Event', @admin_id, 
	  		DateTime.current.to_i + 10, [@admin_id, @other_id])
	  	@event = Event.find(@event_id)
	  	@admin.reload
	  	@other.reload
		end

		describe "when accessing status initially" do
			it "should be correct for admin and nonadmin" do
				@event.get_user_status(@admin_id).should eq STATUS_ATTENDING
				@event.get_user_status(@other_id).should eq STATUS_NO_RESPONSE
			end	
		end

		describe "when changing and accessing status" do
			it "should be correct for admin and nonadmin" do
				@event.set_user_status(@admin_id, STATUS_NOT_ATTENDING)
				@event.get_user_status(@admin_id).should eq STATUS_NOT_ATTENDING
				@event.set_user_status(@other_id, STATUS_ATTENDING)
				@event.get_user_status(@other_id).should eq STATUS_ATTENDING
			end
		end

		describe "when attempting to change status for a user that isn't in the event" do
			it "should do nothing" do
				@event.set_user_status(234573456, STATUS_ATTENDING)
				@event.get_user_status(234573456).should eq nil
			end
		end
	end

	describe "#get_hash" do
		before do
	  	@admin = User.create(name: 'Example User', 
	  		email: 'exampleuser@example.com')
	  	@other = User.create(name: 'Example Friend',
	  		email: 'examplefriend@example.com')
		end

		it "should match the hash data 1" do
			@event_id = Event.add_event('Example Event', @admin.id, 
	  		DateTime.current.to_i + 10, [@admin.id, @other.id])
	  	@event = Event.find(@event_id)
			hash = @event.get_hash
			hash[:event].should eq @event_id
			hash[:title].should eq 'Example Event'
			hash[:creator].should eq @admin.id
			hash[:time].should eq @event.time
			hash[:location].should be_blank
			hash[:description].should be_blank
			hash[:users].should have(3).items
			hash[:users][:user_count].should eq 2
			user_names = [ hash[:users][1][:name], hash[:users][2][:name]]
			user_emails = [ hash[:users][1][:email], hash[:users][2][:email]]
			user_status = [ hash[:users][1][:status], hash[:users][2][:status]]
			user_names.should include("Example User")
			user_names.should include("Example Friend")
			user_emails.should include("exampleuser@example.com")
			user_emails.should include("examplefriend@example.com")
			user_status.should include(STATUS_NO_RESPONSE)
			user_status.should include(STATUS_ATTENDING)
		end


		it "should match the hash data 2" do
			@event_id = Event.add_event('Example Event', @admin.id, 
	  		DateTime.current.to_i + 10, [@admin.id, @other.id], "This is the description of an example event!", "In an example area")
	  	@event = Event.find(@event_id)
			hash = @event.get_hash
			hash[:event].should eq @event_id
			hash[:title].should eq 'Example Event'
			hash[:creator].should eq @admin.id
			hash[:time].should eq @event.time
			hash[:location].should eq "In an example area"
			hash[:description].should eq "This is the description of an example event!"
			hash[:users].should have(3).items
			hash[:users][:user_count].should eq 2
			user_names = [ hash[:users][1][:name], hash[:users][2][:name]]
			user_emails = [ hash[:users][1][:email], hash[:users][2][:email]]
			user_status = [ hash[:users][1][:status], hash[:users][2][:status]]
			user_names.should include("Example User")
			user_names.should include("Example Friend")
			user_emails.should include("exampleuser@example.com")
			user_emails.should include("examplefriend@example.com")
			user_status.should include(STATUS_NO_RESPONSE)
			user_status.should include(STATUS_ATTENDING)
		end
	end
end

describe Event, "conditional acceptances" do
	before do
		@admin = User.new(name: "Test Name", email: "test@example.com",
			password: "test_password")
		@admin.add
		@other1 = User.new(name: "Test Other", email: "t_other@example.com",
			password: "test_password")
		@other1.add
		@other2 = User.new(name: "Test Second", email: "t_other2@example.com",
			password: "test_password")
		@other2.add
		@event_id = Event.add_event("Test Event", @admin.id, 
			DateTime.current.to_i + 10, [@admin.id, @other1.id])
		@event = Event.find(@event_id)
	end
	describe "when adding a conditional acceptance" do
		before do
			cond = NumberCondition.new(3)
			@event.add_condition(@other1.id, cond)
		end
		it "should appear in the party_list but not change status" do
			@event.party_list[@other1.id][:condition][:cond_type].should eq COND_NUM_ATTENDING
			@event.party_list[@other1.id][:condition][:num_users].should eq 3
			@event.party_list[@other1.id][:condition][:cond_met].should eq COND_NOT_MET
			@event.get_user_status(@other1.id).should eq STATUS_NO_RESPONSE
		end
	end

	describe "when removing a conditional acceptance" do
		before do
			cond = NumberCondition.new(3)
			@event.add_condition(@other1.id, cond)
			@event.remove_condition(@other1.id)
		end
		it "should have no condition" do
			@event.party_list[@other1.id][:condition][:cond_type].should eq COND_NONE
		end
		it "should no longer do anything when the condition is met" do
			@event.add_user_list([@other2.id])
			@event.add_to_user_event_lists([@other2.id])
			@event.get_user_status(@other1.id).should eq STATUS_NO_RESPONSE
		end
	end

	describe "when a conditional acceptance is met" do
		describe "ensure that it is detected" do
			before do 
				@other3 = User.new(name: "Test Third", email: "t_other3@example.com",
					password: "test_password")
				@other3.add
				@other4 = User.new(name: "Test Fourth", email: "t_other4@example.com",
					password: "test_password")
				@other4.add
				@other5 = User.new(name: "Test Fifth", email: "t_other5@example.com",
					password: "test_password")
				@other5.add
				@event.add_user_list([@other2.id, @other3.id, @other4.id])
				@event.add_to_user_event_lists([@other2.id, @other3.id, @other4.id])
			end
			# Starting state of event: @admin is attending. @other1-4 are
			# invited but haven't responded. @other5 isn't invited.

			it "should detect when enough other users are attending" do
				cond = NumberCondition.new(5)
				@event.add_condition(@other4.id, cond)
				@event.set_user_status(@other1.id, STATUS_ATTENDING)
				@event.set_user_status(@other2.id, STATUS_ATTENDING)
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.set_user_status(@other3.id, STATUS_ATTENDING)
				@event.get_user_status(@other4.id).should eq STATUS_ATTENDING
				@event.party_list[@other4.id][:condition][:cond_met].should eq COND_MET
			end
			it "should detect when enough other users have number-of-users conditions all with the same number" do
				cond1 = NumberCondition.new(5)
				cond2 = NumberCondition.new(5)
				cond3 = NumberCondition.new(5)
				cond4 = NumberCondition.new(5)
				@event.add_condition(@other1.id, cond1)
				@event.add_condition(@other2.id, cond2)
				@event.add_condition(@other3.id, cond3)
				@event.get_user_status(@other1.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other2.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.add_condition(@other4.id, cond4)
				@event.get_user_status(@other1.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other2.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other4.id).should eq STATUS_ATTENDING
				@event.party_list[@other4.id][:condition][:cond_met].should eq COND_MET
			end
			it "should detect when enough other users have number-of-users conditions all with different numbers" do
				cond1 = NumberCondition.new(4)
				cond2 = NumberCondition.new(6)
				cond3 = NumberCondition.new(3)
				cond4 = NumberCondition.new(4)
				@event.add_condition(@other1.id, cond1)
				@event.add_condition(@other2.id, cond2)
				@event.add_condition(@other3.id, cond3)
				@event.get_user_status(@other1.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other2.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.add_condition(@other4.id, cond4)
				@event.get_user_status(@other1.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other2.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other4.id).should eq STATUS_ATTENDING
				@event.party_list[@other4.id][:condition][:cond_met].should eq COND_MET
				@event.party_list[@other2.id][:condition][:cond_met].should eq COND_NOT_MET
			end
			it "should detect when any of the users join for an any-user-type condition" do
				cond = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other4.id, @other2.id ])
				@event.add_condition(@other3.id, cond)
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.set_user_status(@other2.id, STATUS_ATTENDING)
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.party_list[@other3.id][:condition][:cond_met].should eq COND_MET
			end
			it "should detect when all of the users join for an all-user-type condition" do
				cond = UserCondition.new(COND_USER_ATTENDING_ALL, [ @other4.id, @other2.id ])
				@event.add_condition(@other3.id, cond)
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.set_user_status(@other2.id, STATUS_ATTENDING)
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.party_list[@other3.id][:condition][:cond_met].should eq COND_NOT_MET
				@event.set_user_status(@other4.id, STATUS_ATTENDING)
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.party_list[@other3.id][:condition][:cond_met].should eq COND_MET
			end
			it "should detect a two-person cycle of any-user-type conditions" do
				cond1 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other4.id, @other2.id ])
				cond2 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other3.id ])
				@event.add_condition(@other3.id, cond1)
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE				
				@event.add_condition(@other4.id, cond2)
				@event.get_user_status(@other4.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.party_list[@other4.id][:condition][:cond_met].should eq COND_MET
				@event.party_list[@other3.id][:condition][:cond_met].should eq COND_MET
			end
			it "should detect a cyclic mix of any- and all-user-type conditions when satisfied by a final condition" do
				cond1 = UserCondition.new(COND_USER_ATTENDING_ALL, [ @other4.id, @other2.id ])
				cond2 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other3.id ])
				cond3 = UserCondition.new(COND_USER_ATTENDING_ALL, [ @other4.id, @other3.id, @other1.id ])
				cond4 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other2.id, @other3.id, @other4.id ])
				@event.add_condition(@other3.id, cond1)
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE				
				@event.add_condition(@other4.id, cond2)
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.add_condition(@other2.id, cond3)
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other2.id).should eq STATUS_NO_RESPONSE
				@event.add_condition(@other1.id, cond4)
				@event.get_user_status(@other1.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other2.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other4.id).should eq STATUS_ATTENDING
				@event.party_list[@other4.id][:condition][:cond_met].should eq COND_MET
				@event.party_list[@other3.id][:condition][:cond_met].should eq COND_MET
			end
			it "should detect a cyclic mix of any- and all-user-type conditions when satisfied by a user joining" do
				cond1 = UserCondition.new(COND_USER_ATTENDING_ALL, [ @other4.id, @other2.id ])
				cond2 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other3.id ])
				cond3 = UserCondition.new(COND_USER_ATTENDING_ALL, [ @other4.id, @other3.id, @other1.id ])
				@event.add_condition(@other3.id, cond1)
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.add_condition(@other4.id, cond2)
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.add_condition(@other2.id, cond3)
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.set_user_status(@other1.id, STATUS_ATTENDING)
				@event.get_user_status(@other1.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other2.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other4.id).should eq STATUS_ATTENDING
				@event.party_list[@other4.id][:condition][:cond_met].should eq COND_MET
				@event.party_list[@other3.id][:condition][:cond_met].should eq COND_MET
			end
			it "should detect a longer cycle of any-user-type conditions" do
				cond1 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other2.id ])
				cond2 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other3.id ])
				cond3 = UserCondition.new(COND_USER_ATTENDING_ALL, [ @other4.id ])
				cond4 = UserCondition.new(COND_USER_ATTENDING_ALL, [ @other1.id ])
				@event.add_condition(@other1.id, cond1)
				@event.add_condition(@other2.id, cond2)
				@event.add_condition(@other3.id, cond3)
				@event.get_user_status(@other1.id).should eq STATUS_NO_RESPONSE				
				@event.get_user_status(@other2.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.add_condition(@other4.id, cond4)
				@event.get_user_status(@other1.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other2.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other4.id).should eq STATUS_ATTENDING
				@event.party_list[@other4.id][:condition][:cond_met].should eq COND_MET
				@event.party_list[@other3.id][:condition][:cond_met].should eq COND_MET
			end
			it "should detect a cyclic mix of number-of-users and any-user-type conditions" do

				cond1 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other2.id ])
				cond2 = UserCondition.new(COND_USER_ATTENDING_ANY, [ @other3.id ])
				cond3 = UserCondition.new(COND_USER_ATTENDING_ALL, [ @other4.id ])
				cond4 = NumberCondition.new(5)
				@event.add_condition(@other1.id, cond1)
				@event.add_condition(@other2.id, cond2)
				@event.add_condition(@other3.id, cond3)
				@event.get_user_status(@other1.id).should eq STATUS_NO_RESPONSE				
				@event.get_user_status(@other2.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other3.id).should eq STATUS_NO_RESPONSE
				@event.get_user_status(@other4.id).should eq STATUS_NO_RESPONSE
				@event.add_condition(@other4.id, cond4)
				@event.get_user_status(@other1.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other2.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other3.id).should eq STATUS_ATTENDING
				@event.get_user_status(@other4.id).should eq STATUS_ATTENDING
				@event.party_list[@other4.id][:condition][:cond_met].should eq COND_MET
				@event.party_list[@other3.id][:condition][:cond_met].should eq COND_MET
			end
		end

		describe "proper actions should result" do
			before do
				@cond = NumberCondition.new(3)
				@event.add_condition(@other1.id, @cond)
				@event.add_user_list([@other2.id])
				@event.add_to_user_event_lists([@other2.id])
				@event.set_user_status(@other2.id, STATUS_ATTENDING)
			end

			it "should notify the user" do
				@other2.notification_list.first[:notif_type].should eq NOTIF_COND_MET
				@other2.notification_list.first[:event].should eq @event_id
				@other2.notification_list.first[:condition][:cond_met].should eq COND_MET
				@other2.notification_list.first[:condition][:cond_type].should eq COND_NUM_ATTENDING
				@other2.notification_list.first[:condition][:num_users].should eq 3
			end

			it "should change that user's status to STATUS_ATTENDING" do
				@event.get_user_status(@other2.id).should eq STATUS_ATTENDING
			end

			it "should change the status of the condition to COND_MET" do
				@cond.met?.should be_true
			end
		end
	end
end