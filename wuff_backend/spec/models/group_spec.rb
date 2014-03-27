require 'spec_helper'

describe Group, "creation" do
	  
  before do
  	@user1 = User.create(name: 'Example User', 
  		email: 'exampleuser@example.com')
  	@user1_id = @user1.id
  	@user2 = User.create(name: 'Example Friend',
  		email: 'examplefriend@example.com')
  	@user2_id = @user2.id
	end

	describe "when everything is valid" do
		before do
			@group_id = Group.add_group('Example Group', [@user1_id, @user2_id],
				'Awesome example group!')
			@user1.reload
			@user2.reload
		end
		specify { @group_id.should be > 0 }

		describe "the group_list of the users involved" do
			specify { @user1.group_list.should include(@group_id) }
			specify { @user2.group_list.should include(@group_id) }
		end
	end

	describe "when everything is valid and description is ommitted" do
		before do
			@group_id = Group.add_group('Example Group', [@user1_id, @user2_id])
			@user1.reload
			@user2.reload
		end
		specify { @group_id.should be > 0 }

		describe "the group_list of the users involved" do
			specify { @user1.group_list.should include(@group_id) }
			specify { @user2.group_list.should include(@group_id) }
		end
	end

	describe "when name field" do
		describe "is empty" do
			before { @group_id = Group.add_group('', [@user1_id]) }
			specify { @group_id.should eq ERR_INVALID_NAME }
		end
		describe "is too long" do
			before { @group_id = Group.add_group('A' * (NAME_MAX_LENGTH + 1),
				[@user1_id]) }
			specify { @group_id.should eq ERR_INVALID_NAME }
		end
	end

	describe "when user_list" do
		describe "is not an array" do
			before { @group_id = Group.add_group('Ex Name', '') }
			specify { expect(@group_id).to eq(ERR_INVALID_FIELD) }
		end
		describe "is an empty array" do
			before { @group_id = Group.add_group('Ex Name', []) }
			specify { expect(@group_id).to eq(ERR_INVALID_FIELD) }
		end
		describe "contains invalid users" do
			before { @group_id = Group.add_group('Ex Name', [@user1_id, @user2_id, 23402234]) }
			specify { expect(@group_id).to eq(ERR_INVALID_FIELD) }
		end
	end
end

describe Group, "misc" do

	describe "get_hash" do
		before do
	  	@user1 = User.create(name: 'Example User', 
	  		email: 'exampleuser@example.com')
	  	@user2 = User.create(name: 'Example Friend',
	  		email: 'examplefriend@example.com')
		end

		it "should match the hash data 1" do
			@group_id = Group.add_group('Example Group', [@user1.id, @user2.id])
	  	@group = Group.find(@group_id)
			hash = @group.get_hash
			hash[:group].should eq @group_id
			hash[:name].should eq 'Example Group'
			hash[:description].should be_blank
			hash[:users].should have(3).items
			hash[:users][:user_count].should eq 2
			user_names = [ hash[:users][1][:name], hash[:users][2][:name]]
			user_emails = [ hash[:users][1][:email], hash[:users][2][:email]]
			user_names.should include("Example User")
			user_names.should include("Example Friend")
			user_emails.should include("exampleuser@example.com")
			user_emails.should include("examplefriend@example.com")
		end

		it "should match the hash data 2" do
			@group_id = Group.add_group('Example Group', 
	  		[@user1.id, @user2.id], "Description of an example group")
	  	@group = Group.find(@group_id)
			hash = @group.get_hash
			hash[:group].should eq @group_id
			hash[:name].should eq 'Example Group'
			hash[:description].should eq "Description of an example group"
			hash[:users].should have(3).items
			hash[:users][:user_count].should eq 2
			user_names = [ hash[:users][1][:name], hash[:users][2][:name]]
			user_emails = [ hash[:users][1][:email], hash[:users][2][:email]]
			user_names.should include("Example User")
			user_names.should include("Example Friend")
			user_emails.should include("exampleuser@example.com")
			user_emails.should include("examplefriend@example.com")
		end
	end
end