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
				be_close(DateTime.current.to_i, 1) }
			specify { @other.notification_list.first[:event].should eq @event_id }
			specify { @other.notification_list.first[:name].should eq "Example Event" }
			specify { @other.notification_list.first[:location].should eq "" }
			specify { @other.notification_list.first[:creator].should eq @admin_id }

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
	end

	describe "getHash" do
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
			hash = @event.getHash
			hash[:event].should eq @event_id
			hash[:name].should eq 'Example Event'
			hash[:creator].should eq @admin.id
			hash[:time].should eq @event.time
			hash[:location].should be_blank
			hash[:users].split(',').should have(2).items
			hash[:users].split(',').should include(@admin.id.to_s)
			hash[:users].split(',').should include(@other.id.to_s)
			hash[:status_list].split(',').should include(STATUS_ATTENDING.to_s)
			hash[:status_list].split(',').should include(STATUS_NO_RESPONSE.to_s)
		end
	end
end