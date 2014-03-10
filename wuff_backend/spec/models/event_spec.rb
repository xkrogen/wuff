require 'spec_helper'

NAME_MAX_LENGTH = 40

# Invalid time: Time must be a valid time
ERR_INVALID_TIME = -10

# Possible user statuses in respect to an event. 
STATUS_NO_RESPONSE = 0
STATUS_ATTENDING = 1
STATUS_NOT_ATTENDING = -1

describe Event do
	  
  before { @event = Event.new(name: 'Example Event', admin: 1, party_list: {1 => {status: STATUS_ATTENDING}}, time: (DateTime.current.to_i + 10)) }

	subject { @event }

	it { should respond_to(:name) }
	it { should respond_to(:admin) }
	it { should respond_to(:description) }
	it { should respond_to(:location) }
	it { should respond_to(:time) }
	it { should respond_to(:party_list) }

	specify { expect(@event.is_valid?).to eq(SUCCESS) }

	describe "when name field" do
		describe "is empty" do
			before { @event.name = '' }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_NAME) }
		end
		describe "is too long" do
			before { @event.name = 'a' * (NAME_MAX_LENGTH + 1) }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_NAME) }
		end
	end

	describe "when admin field is empty" do
		before { @event = Event.new(name: "Event", party_list: {}, time: (DateTime.current.to_i + 10)) }
		specify { expect(@event.is_valid?).to eq(ERR_INVALID_FIELD) }
	end

	describe "when party list" do
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

	describe "when time" do
		describe "is far in the future" do
			before { @event.time = DateTime.current.to_i + 10000000 }
			specify { expect(@event.is_valid?).to eq(SUCCESS) }
		end
		describe "is in the past" do
			before { @event.time = DateTime.current.to_i - 20 }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_TIME) }
		end
		describe "is negative" do
			before { @event.time = -50 }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_TIME) }
		end
		describe "is zero" do
			before { @event.time = 0 }
			specify { expect(@event.is_valid?).to eq(ERR_INVALID_TIME) }
		end
	end

end
