require 'net/http'

BASEURL = 'http://wuff.herokuapp.com'
#BASEURL = 'http://localhost:3000'

SKIP_TESTS = true

# Declare an exclusion filter so that these tests are normally disabled. 
RSpec.configure do |c|
  c.filter_run_excluding :external_server => true
end

describe "submitting many rapid requests to the heroku server", :external_server => SKIP_TESTS do
	before do
		@login_uri = URI(BASEURL + '/user/login_user')
		@update_status_uri = URI(BASEURL + '/event/update_user_status')
		@get_events_uri = URI(BASEURL + '/user/get_events')

		req = Net::HTTP::Post.new(@login_uri)
		req.content_type = 'application/json'
		req.body = '{"email": "test@gmail.com", "password": "password"}'

		uri = @login_uri
		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
		  http.request(req)
		end

		#puts "RESPONSE CODE 1: #{res.code}"
		#puts "RESPONSE BODY 1: #{res.body}"

		@tester_token = /current_user_token=([^;]+)/.match(res['Set-Cookie'])[1].to_s

		req = Net::HTTP::Post.new(@login_uri)
		req.content_type = 'application/json'
		req.body = '{"email": "test2@gmail.com", "password": "password"}'

		uri = @login_uri
		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
		  http.request(req)
		end

		#puts "RESPONSE CODE 2: #{res.code}"
		#puts "RESPONSE BODY 2: #{res.body}"

		@tester2_token = /current_user_token=([^;]+)/.match(res['Set-Cookie'])[1].to_s

# get_events testing code
=begin
		token = /current_user_token=([^;]+)/.match(res['Set-Cookie'])[1].to_s
		req = Net::HTTP::Get.new(@get_events_uri)
		req.add_field('Cookie', "current_user_token=" + tester2_token)
		uri = get_events_uri
		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
		  http.request(req)
		end
		puts "RESPONSE CODE 2: #{res.code}"
		puts "RESPONSE BODY 2: #{res.body}"
=end
	end

	it "should print out the body for now" do
		20.times do
			change_status(@tester_token, 1, -1).split(':')[1][0].should eq '1'
			change_status(@tester2_token, 92, -1).split(':')[1][0].should eq '1'
			change_status(@tester_token, 1, 1).split(':')[1][0].should eq '1'
			change_status(@tester2_token, 92, 1).split(':')[1][0].should eq '1'
		end
	end
end

def change_status(user_token, event, new_status) 
	uri = @update_status_uri
	req = Net::HTTP::Post.new(uri)
	req.content_type = 'application/json'
	req.body = "{\"event\": #{event}, \"status\": #{new_status}}"
	req.add_field('Cookie', "current_user_token=" + user_token)

	res = Net::HTTP.start(uri.hostname, uri.port) do |http|
	  http.request(req)
	end
	return res.body
end