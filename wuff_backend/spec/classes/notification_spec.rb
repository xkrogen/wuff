
require 'spec_helper'
require 'EventNotification'
require 'FriendNotification'

describe EventNotification do
	
	before { @event = Event.create(name: "My event!", admin: 2, 
		party_list: { 2 => {status: STATUS_ATTENDING} }, 
		time: DateTime.current.to_i + 10) }

	describe "when creating notification for a new event" do
		before { @notif = EventNotification.new(NOTIF_NEW_EVENT, @event) }
		it "should return proper notification" do
			n_hash = @notif.getHash
			n_hash[:notif_type].should eq(NOTIF_NEW_EVENT)
			n_hash[:event].should eq(@event.id)
			n_hash[:name].should eq(@event.name)
			n_hash[:creator].should eq(@event.admin)
			curr_time = DateTime.current.to_i
			# Allow a one-second difference in case the time changed
			((n_hash[:notif_time] == curr_time) || (n_hash[:notif_time] == curr_time - 1)).should be_true
			n_hash[:location].should eq(@event.location)
		end
	end
end

describe FriendNotification do
	
	before { @user = User.create(name: "My Friend", email: "friend@example.com") }

	describe "when creating notification for a new friend add" do
		before { @notif = FriendNotification.new(@user) }
		it "should return proper notification" do
			n_hash = @notif.getHash
			n_hash[:notif_type].should eq(NOTIF_FRIEND_ADD)
			n_hash[:friend_name].should eq(@user.name)
			n_hash[:friend_email].should eq(@user.email)
			curr_time = DateTime.current.to_i
			# Allow a one-second difference in case the time changed
			((n_hash[:notif_time] == curr_time) || (n_hash[:notif_time] == curr_time - 1)).should be_true
		end
	end
end