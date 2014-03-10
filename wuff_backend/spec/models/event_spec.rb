require 'spec_helper'

NAME_MAX_LENGTH = 40

describe Event do
	  
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
			it "should have the current notification time" do
				n_time = 	@other.notification_list.first[:notif_time]	
				curr_time = DateTime.current.to_i
				((n_time == curr_time) || (n_time == curr_time - 1)).should be_true
			end
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
