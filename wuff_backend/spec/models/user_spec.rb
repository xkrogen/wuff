# Unit Tests for User model.
require 'spec_helper'

describe User, " UNIT TESTS" do

	before do
		@user = User.new(name: "Bob", email: "user@example.com")
	end

	subject { @user }

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }

end
#context "TEST1: Try to add duplicate users" do
#		it "returns ERR_USER_EXISTS" do
#  		  	user = UsersModel.new(user: "Ex", password: "nopassword")
#  		  	same_user = user.dup
#  		  	user.add
#  		  	same_user.add.should eq(ERR_USER_EXISTS)
#  	end
#  end
