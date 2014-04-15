require 'spec_helper'

require 'Condition'
require 'UserCondition'
require 'NumberCondition'

describe UserCondition do
	before do
		@user1 = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
		@user1.add
		@user2 = User.new(name: "Foo Bar", email: "test2@example.com",
				password: "test_password")
		@user2.add
		@user_cond = UserCondition.new(COND_USER_ATTENDING_ANY, [@user1.id, 
			@user2.id])
	end
	specify { @user_cond.met?.should be_false }
	describe "when converting to/from a hash" do 
		it "should match the object" do
			cond_hash = @user_cond.get_hash
			cond_hash[:cond_type].should eq COND_USER_ATTENDING_ANY
			cond_hash[:cond_met].should eq COND_NOT_MET
			cond_hash[:user_list][:user_count].should eq 2
			cond_hash[:user_list][1][:name].should eq 'Test Name'
			cond_hash[:user_list][2][:name].should eq 'Foo Bar'
			cond_hash[:user_list][1][:email].should eq 'test@example.com'
			cond_hash[:user_list][2][:email].should eq 'test2@example.com'		
			cond_copy = Condition.create_from_hash(cond_hash)
			cond_copy.instance_variable_get(:@user_ids).should include(@user1.id)
			cond_copy.instance_variable_get(:@user_ids).should include(@user2.id)
			cond_copy.instance_variable_get(:@cond_met).should eq COND_NOT_MET
			cond_copy.met?.should be_false
			cond_copy.instance_variable_get(:@cond_type).should eq COND_USER_ATTENDING_ANY
		end
	end
end

describe NumberCondition do
	before { @num_cond = NumberCondition.new(4) } 
	specify { @num_cond.met?.should be_false }
	describe "when converting to/from a hash" do 
		it "should match the object" do
			cond_hash = @num_cond.get_hash
			cond_hash[:cond_type].should eq COND_NUM_ATTENDING
			cond_hash[:cond_met].should eq COND_NOT_MET
			cond_hash[:num_users].should eq 4
			cond_copy = Condition.create_from_hash(cond_hash)
			cond_copy.instance_variable_get(:@cond_met).should eq COND_NOT_MET
			cond_copy.met?.should be_false
		end
	end
end