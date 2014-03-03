# Unit Tests for User model.
require 'spec_helper'


=begin
	before do
		@user = User.new(name: "Bob", email: "user@example.com")
	end

	subject { @user }

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }

end
=end
#context "TEST1: Try to add duplicate users" do
#		it "returns ERR_USER_EXISTS" do
#  		  	user = UsersModel.new(user: "Ex", password: "nopassword")
#  		  	same_user = user.dup
#  		  	user.add
#  		  	same_user.add.should eq(ERR_USER_EXISTS)
#  	end
#  end
# Success return code
SUCCESS = 1
# Invalid name: must be VALID_NAME_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
ERR_INVALID_NAME = -1
# Invalid email: must be VALID_EMAIL_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
ERR_INVALID_EMAIL = -2
# Password cannot be longer than MAX_CREDENTIAL_LENGTH or shorter than MIN_PW_LENGTH
ERR_INVALID_PASSWORD = -3
# Email is not unique (i.e. exists already in database)
ERR_EMAIL_TAKEN = -4
# Cannot find the email/password pair in the database (i.e. login fail)
ERR_BAD_CREDENTIALS = -5
# Generic error for an invalid property
ERR_INVALID_FIELD = -6
# Generic error for an unseccessful action
ERR_UNSUCCESSFUL = -7

describe User, "#add" do

	describe ":name field" do
		context ":name can contain alphabet characters with space characters in between" do
			it "returns SUCCESS" do
				user = User.new(name: "Bob SmItH", email: "user@example.com", password: "nopassword")
				user.add.should eq(SUCCESS)
			end
		end

		context ":name is an empty string" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: "", email: "user@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end

		context ":name contains number characters" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: "a1b2c", email: "user@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end

		context ":name contains non-alphabet characters" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: "S+ap*_G ^&", email: "user@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end

		context ":name contains leading white-space characters" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: " David", email: "user@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end

		context ":name contains trailing white-space characters" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: "Ashley ", email: "user@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end
	end

	describe ":email field" do
		context ":email can contain dot characters" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "lebron.james@example.com", password: "nopassword")
				user.add.should eq(SUCCESS)
			end
		end

		context ":email can contain underscore characters" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "lebron_james@example.com", password: "nopassword")
				user.add.should eq(SUCCESS)
			end
		end

		context ":email can contain hypen characters" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "lebron-james@example.com", password: "nopassword")
				user.add.should eq(SUCCESS)
			end
		end

		context ":email can contain number characters" do
			it "returns SUCCESS" do
				user = User.new(name: "West", email: "Yeezus2000@example.com", password: "nopassword")
				user.add.should eq(SUCCESS)
			end
		end


		context ":email can contain underscore characters" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "lebron_james@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_EMAIL)
			end
		end

		context ":email cannot have white-space characters" do
			it "returns ERR_INVALID_EMAIL" do
				user = User.new(name: "John", email: "user @example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_EMAIL)
			end
		end

		context ":email has no domain" do
			it "returns ERR_INVALID_EMAIL" do
				user = User.new(name: "John", email: "user@example.", password: "nopassword")
				user.add.should eq(ERR_INVALID_EMAIL)
			end
		end
	end

	describe ":password field" do
		context ":password can contain any character" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "user@example.com", password: "s%88! $sfa#0 0!ADSff")
				user.add.should eq(SUCCESS)
			end
		end

		context ":password cannot be less than 6 characters" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "user@example.com", password: "a2d4f")
				user.add.should eq(ERR_INVALID_PASSWORD)
			end
		end

		context ":password cannot be more than 128 characters" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "user@example.com", password: "a" * 129)
				user.add.should eq(ERR_INVALID_PASSWORD)
			end
		end
	end

end


