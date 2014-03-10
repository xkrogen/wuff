# Unit Tests for User model.
require 'spec_helper'

describe User, "#add" do

	describe ":name field" do
		context ":name can be sequence of alphabet characters with one space character in between" do
			it "returns SUCCESS" do
				user = User.new(name: "Bob SmItH", email: "user0@example.com", password: "nopassword")
				user.add.should eq(SUCCESS)
			end
		end

		context ":name can contain dot and colon characters" do
			it "returns SUCCESS" do
				user = User.new(name: "J.R. O'Brian", email: "user1@example.com", password: "nopassword")
				user.add.should eq(SUCCESS)
			end
		end

		context ":name cannot be an empty string" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: "", email: "user2@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end

		context ":name cannot contain number characters" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: "a1b2c", email: "user3@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end

		context ":name cannot contain non-alphabet characters other than dot and colon" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: "S+ap*_G ^&", email: "user4@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end

		context ":name cannot contains leading white-space characters" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: " David", email: "user5@example.com", password: "nopassword")
				user.add.should eq(ERR_INVALID_NAME)
			end
		end

		context ":name contains trailing white-space characters" do
			it "returns ERR_INVALID_NAME" do
				user = User.new(name: "Ashley ", email: "user6@example.com", password: "nopassword")
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

		context ":email is unique" do
			it "returns ERR_EMAIL_TAKEN" do
				user = User.new(name: "Jimmy", email: "taken@email.com", password: "foobar")
				user.add
				other =User.new(name: "Tommy", email: "taken@email.com", password: "helloworld")
				other.add.should eq(ERR_EMAIL_TAKEN)
			end
		end
	end

	describe ":password field" do
		context ":password can contain any character" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "password0@example.com", password: "s%88! $sfa#0 0!ADSff")
				user.add.should eq(SUCCESS)
			end
		end

		context ":password cannot be less than 6 characters" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "password1@example.com", password: "a2d4f")
				user.add.should eq(ERR_INVALID_PASSWORD)
			end
		end

		context ":password cannot be more than 128 characters" do
			it "returns SUCCESS" do
				user = User.new(name: "John", email: "password2@example.com", password: "a" * 129)
				user.add.should eq(ERR_INVALID_PASSWORD)
			end
		end
	end

	describe ":remember_token field" do
		context "after added in db" do
			it "should not be nil" do
				user = User.new(name: "John", email: "John@example.com", password: "foobar")
				user.add
				user.remember_token.should_not eq(nil)
			end
		end
	end
end

describe User, "#login" do
	before(:each) do
		@user = User.new(name: "Hello World", email: "hello@world.com", password: "nopassword")
		@user.add
	end

	context "with correct credentials" do
		it "should have success, err_code: SUCCESS" do
			other = User.new(email: "hello@world.com", password: "nopassword")
			other.login[:err_code].should eq(SUCCESS)
		end
	end

	context "with unregistered email" do
		it "should have error, errorCode: ERR_BAD_CREDENTIALS" do
			other = User.new(email: "bye@world.com", password: "nopassword")
			other.login[:err_code].should eq(ERR_BAD_CREDENTIALS)
		end
	end

	context "with wrong password" do
		it "should have error, err_code: ERR_BAD_CREDENTIALS" do
			other = User.new(email: "hello@world.com", password: "yespassword")
			other.login[:err_code].should eq(ERR_BAD_CREDENTIALS)
		end
	end
end

