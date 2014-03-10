require 'spec_helper'
require 'json'

describe EventsController do
	
	describe "when creating an event" do
		
	end

end

=begin

describe UsersController do

	describe "when submitting login attempts" do
		before { User.add("testuser", "password") }

		describe "with valid requests" do
			before { post 'login', { format: 'json', user: 'testuser',
																							 password: 'password' } }
			it "should respond with good status code" do
				expect(response.status).to eq 200
			end
			it "should return errCode of SUCCCESS" do
				expect(JSON.parse(response.body)["errCode"]).to eq SUCCESS
			end
			it "should return count of user logins" do
				expect(JSON.parse(response.body)["count"]).to eq 2
			end
		end

		describe "with invalid requests" do
			before { post 'login', { format: 'json', user: 'testuser',
																							 password: 'password2' } }
			it "should respond with good status code" do
				expect(response.status).to eq 200
			end
			it "should NOT return errCode of SUCCCESS" do
				expect(JSON.parse(response.body)["errCode"]).to eq ERR_BAD_CREDENTIALS
			end
		end
	end

=end