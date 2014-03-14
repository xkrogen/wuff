require 'spec_helper'

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

	describe "get_hash" do
		before do
	  	@admin = User.create(name: 'Example User', 
	  		email: 'exampleuser@example.com')
	  	@other = User.create(name: 'Example Friend',
	  		email: 'examplefriend@example.com')
	  	@event_id = Event.add_event('Example Event', @admin.id, 
	  		DateTime.current.to_i + 10, [@admin.id, @other.id])
	  	@event = Event.find(@event_id)
		end

		it "should match the hash data" do
			hash = @event.get_hash
			hash[:event].should eq @event_id
			hash[:name].should eq 'Example Event'
			hash[:creator].should eq @admin.id
			hash[:time].should eq @event.time
			hash[:location].should be_blank
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