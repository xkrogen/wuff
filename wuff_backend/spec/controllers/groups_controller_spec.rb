require 'spec_helper'
require 'json'

describe GroupsController do

	describe "when creating a group (group/create_group)" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@token = User.new_token
			@user.update_attribute(:remember_token, User.hash(@token))
			@request.cookies['current_user_token'] = @token
		end

		describe "with valid inputs, no description" do
			before do
				@other = User.new(name: "Test Other", email: "t_other@example.com",
					password: "test_password")
				@other.add
				post 'create_group', { format: 'json', 
					user_list: "#{@user.email},#{@other.email}",
					name: "Test Group" }
				@user.reload
				@other.reload
				@group_id = JSON.parse(response.body)['group']
			end

			specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }

			describe "the group_list of the users involved" do
				specify { @user.group_list.should include(@group_id) }
				specify { @other.group_list.should include(@group_id) }
			end

			describe "the created group" do
				before { @group = Group.find(@group_id) }
				specify { @group.name.should eq "Test Group" }
				specify { @group.description.should eq '' }
			end
		end

		describe "with valid inputs including description" do
			before do
				@other = User.new(name: "Test Other", email: "t_other@example.com",
					password: "test_password")
				@other.add
				post 'create_group', { format: 'json', 
					user_list: "#{@user.email},#{@other.email}",
					name: "Test Group", description: "Test Group Here" }
				@user.reload
				@other.reload
				@group_id = JSON.parse(response.body)['group']
			end

			specify { JSON.parse(response.body)['err_code'].should eq SUCCESS }

			describe "the group_list of the users involved" do
				specify { @user.group_list.should include(@group_id) }
				specify { @other.group_list.should include(@group_id) }
			end

			describe "the created group" do
				before { @group = Group.find(@group_id) }
				specify { @group.name.should eq "Test Group" }
				specify { @group.description.should eq "Test Group Here" }
			end
		end

		describe "while not logged in" do
			before { @request.cookies['current_user_token'] = 'invalid token' }

			it "should return err_code of ERR_INVALID_SESSION" do
				post 'create_group', { format: 'json', user_list: @user.email,
					title: "Test Group" }

				response.status.should eq 200
				JSON.parse(response.body)['err_code'].should eq ERR_INVALID_SESSION
				Group.find_by(name: "Test Group").should eq nil
			end
		end

		describe "with invalid/missing inputs" do
			describe " - missing name" do
				before { post 'create_group', { format: 'json', 
					user_list: @user.email } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_NAME }
			end
			describe " - missing user_list" do
				before { post 'create_group', { format: 'json', 
					name: "Test Group" } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - invalid user_list 1" do
				before { post 'create_group', { format: 'json', 
					name: "Test Group", user_list: "userid"} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
			describe " - invalid user_list 2" do
				before { post 'create_group', { format: 'json', 
					name: "Test Group", user_list: "#{@user.email},userid"} }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD }
			end
		end
	end

	describe "when adding new users (group/add_users)" do

		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@group_id = Group.add_group("Test Group", [@user.id, @other.id])
			@group = Group.find(@group_id)
			@user_token = User.new_token
			@user.reload
			@other.reload
			@user.update_attribute(:remember_token, User.hash(@user_token))
			@new_user1 = User.new(name: "Friend One", email: "friend1@example.com",
				password: "test_password")
			@new_user1.add
			@new_user2 = User.new(name: "Friend Two", email: "friend2@example.com",
				password: "test_password")
			@new_user2.add
			@new_user1.reload
			@new_user2.reload
		end

		describe "when adding as member of the group" do
			before { @request.cookies['current_user_token'] = @user_token }
			describe "with all valid users" do
				before do
					post 'add_users', { format: 'json', group: @group_id,
						user_list: "friend1@example.com,friend2@example.com" }
					@user.reload
					@other.reload
					@new_user1.reload
					@new_user2.reload
				end
				it "should be successful" do
					JSON.parse(response.body)['err_code'].should eq SUCCESS
					@user.group_list.should include(@group_id)
					@other.group_list.should include(@group_id) 
					@new_user1.group_list.should include(@group_id)
					@new_user2.group_list.should include(@group_id) 
					@group.reload
					@group.user_list.should include(@new_user1.id)
					@group.user_list.should include(@new_user2.id)
				end				 
			end

			describe "with an invalid user" do
				before do
					post 'add_users', { format: 'json', group: @group_id,
						user_list: "ran_email_bad@example.com,friend2@example.com" }
					@user.reload
					@other.reload
					@new_user1.reload
					@new_user2.reload
				end
				it "should return an error" do
					JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD
					@user.group_list.should include(@group_id)
					@other.group_list.should include(@group_id) 
					@new_user1.group_list.should_not include(@group_id)
					@new_user2.group_list.should_not include(@group_id) 
					@group.reload
					@group.user_list.should_not include(@new_user1.id)
					@group.user_list.should_not include(@new_user2.id)
				end	
			end

			describe "with a duplicate user" do
				before do
					post 'add_users', { format: 'json', group: @group_id,
						user_list: "t_other@example.com,friend2@example.com" }
					@user.reload
					@other.reload
					@new_user1.reload
					@new_user2.reload
				end
				it "should be successful but ignore duplicate" do
					JSON.parse(response.body)['err_code'].should eq SUCCESS
					@user.group_list.should include(@group_id)
					@other.group_list.should include(@group_id) 
					@other.group_list.should have(1).items
					@new_user2.group_list.should include(@group_id) 
					@group.reload
					@group.user_list.should have(3).items
					@group.user_list.should include(@new_user2.id)
					@group.user_list.should_not include(@new_user1.id)
				end	
			end
		end

		describe "when adding as a non-member" do
			before do
				new_user1_token = User.new_token
				@new_user1.update_attribute(:remember_token, User.hash(new_user1_token))
				@request.cookies['current_user_token'] = new_user1_token
				post 'add_users', { format: 'json', group: @group_id,
					user_list: "friend1@example.com,friend2@example.com" }
				@user.reload
				@other.reload
				@new_user1.reload
				@new_user2.reload
			end
			it "should fail with an error" do
				JSON.parse(response.body)['err_code'].should eq ERR_INVALID_PERMISSIONS
				@user.group_list.should include(@group_id)
				@other.group_list.should include(@group_id) 
				@new_user1.group_list.should_not include(@group_id)
				@new_user2.group_list.should_not include(@group_id) 
				@group.reload
				@group.user_list.should_not include(@new_user1.id)
				@group.user_list.should_not include(@new_user2.id)
			end	
		end

		describe "when adding to an invalid group" do
			before do
				@request.cookies['current_user_token'] = @user_token
				post 'add_users', { format: 'json', group: 93452345,
					user_list: "friend1@example.com,friend2@example.com" }
				@user.reload
				@other.reload
				@new_user1.reload
				@new_user2.reload
			end
			it "should fail with an error" do
				JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD
				@user.group_list.should include(@group_id)
				@other.group_list.should include(@group_id) 
				@new_user1.group_list.should_not include(93452345)
				@new_user2.group_list.should_not include(93452345) 
				@group.reload
			end	
		end
	end

	describe "when viewing a group (group/view)" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@group1_id = Group.add_group("Test Group 1", [@user.id, @other.id], "Testing Group")
			@group1 = Group.find(@group1_id)
			@group2_id = Group.add_group("Test Group 2", [@user.id, @other.id])
			@group2 = Group.find(@group2_id)
			@user_token = User.new_token
			@user.reload
			@other.reload
			@user.update_attribute(:remember_token, User.hash(@user_token))
		end

		it "should fail if the user isn't signed in" do
			@request.cookies['current_user_token'] = 'aBdsfg135_123'
			post 'view', { format: 'json', group: @group1_id }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_SESSION
		end

		it "should fail if requested from a nonmember" do
			user2 = User.new(name: "User Two", email: "user2@example.com", 
				password: "test_password")
			user2_token = User.new_token
			user2.update_attribute(:remember_token, User.hash(user2_token))
			@request.cookies['current_user_token'] = user2_token
			post 'view', { format: 'json', group: @group1_id }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_PERMISSIONS
		end

		it "should fail if the group ID isn't valid" do
			@request.cookies['current_user_token'] = @user_token
			post 'view', { format: 'json', group: 234525731 }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_FIELD
		end

		it "should return the correct fields for group 1" do
			@request.cookies['current_user_token'] = @user_token
			post 'view', { format: 'json', group: @group1_id }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			JSON.parse(response.body)['group'].should eq @group1_id
			JSON.parse(response.body)['name'].should eq "Test Group 1"
			JSON.parse(response.body)['users']['user_count'].should eq 2
			JSON.parse(response.body)['description'].should eq "Testing Group"
		end

		it "should return the correct fields for group 2" do
			@request.cookies['current_user_token'] = @user_token
			post 'view', { format: 'json', group: @group2_id }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			JSON.parse(response.body)['group'].should eq @group2_id
			JSON.parse(response.body)['name'].should eq "Test Group 2"
			JSON.parse(response.body)['users']['user_count'].should eq 2
			JSON.parse(response.body)['description'].should eq ""
		end
	end

	describe "when removing a user (group/remove_user)" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@group_id = Group.add_group("Test Group", [@user.id, @other.id])
			@group = Group.find(@group_id)
			@user_token = User.new_token
			@user.reload
			@other.reload
			@user.update_attribute(:remember_token, User.hash(@user_token))
		end

		it "should do nothing if attempted by a user not in the group" do
			new_user = User.new(name: "Test Other", email: "test99@example.com",
				password: "test_password")
			new_user.add
			new_user_token = User.new_token
			new_user.update_attribute(:remember_token, User.hash(new_user_token))
			@request.cookies['current_user_token'] = new_user_token
			delete 'remove_user', { format: 'json', group: @group_id, 
				user_remove: @user.email }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_PERMISSIONS
			@user.reload
			@group.reload
			@other.reload
			@group.user_list.should include(@user.id)
		end

		it "should do nothing if attempting to remove a user not in the group" do
			new_user = User.new(name: "Test Other", email: "test99@example.com",
				password: "test_password")
			new_user.add
			@request.cookies['current_user_token'] = @user_token
			delete 'remove_user', { format: 'json', group: @group_id, 
				user_remove: new_user.email }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@user.reload
			@group.reload
			@other.reload
			@group.user_list.should include(@user.id)
			@group.user_list.should include(@other.id)
			@group.user_list.should_not include(new_user.id)
		end

		it "should properly remove a valid other user" do
			@request.cookies['current_user_token'] = @user_token
			delete 'remove_user', { format: 'json', group: @group_id, 
				user_remove: @other.email }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@user.reload
			@group.reload
			@other.reload
			@user.group_list.should include(@group_id)
			@group.user_list.should include(@user.id)

			@group.user_list.should_not include(@other.id)
			@other.group_list.should_not include(@group_id)
		end

		it "should properly remove itself if valid user" do
			@request.cookies['current_user_token'] = @user_token
			delete 'remove_user', { format: 'json', group: @group_id, 
				user_remove: @user.email }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@user.reload
			@group.reload
			@other.reload
			@user.group_list.should_not include(@group_id)
			@group.user_list.should_not include(@user.id)

			@group.user_list.should include(@other.id)
			@other.group_list.should include(@group_id)
		end
	end

	describe "when deleting a group (group/delete_group)" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@group_id = Group.add_group("Test Group", [@user.id, @other.id], "Testing Group")
			@group = Group.find(@group_id)
			@user_token = User.new_token
			@user.reload
			@user.update_attribute(:remember_token, User.hash(@user_token))
		end

		it "should do nothing if a nonmember cancels it" do
			new_user = User.new(name: "New User", email: "new@example.com",
				password: "test_password")
			new_user.add
			new_user_token = User.new_token
			new_user.update_attribute(:remember_token, User.hash(new_user_token))
			@request.cookies['current_user_token'] = new_user_token
			delete 'delete_group', { format: 'json', group: @group_id }
			@user.reload
			@group.reload
			@other.reload
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_PERMISSIONS
			@user.group_list.should include(@group_id)
			@other.group_list.should include(@group_id)
			@group.user_list.should include(@user.id)
			@group.user_list.should include(@other.id)
		end

		it "should properly cancel a valid group" do
			@request.cookies['current_user_token'] = @user_token
			delete 'delete_group', { format: 'json', group: @group_id }
			JSON.parse(response.body)['err_code'].should eq SUCCESS
			@user.reload
			@other.reload
			@user.group_list.should_not include(@group_id)
			@other.group_list.should_not include(@group_id)
			expect { Group.find(@group_id) }.to raise_error(ActiveRecord::RecordNotFound)
		end
	end

	describe "when editing a group (group/edit_group)" do
		before do
			@user = User.new(name: "Test Name", email: "test@example.com",
				password: "test_password")
			@user.add
			@user_token = User.new_token
			@user.update_attribute(:remember_token, User.hash(@user_token))
			@request.cookies['current_user_token'] = @user_token
			@other = User.new(name: "Test Other", email: "t_other@example.com",
				password: "test_password")
			@other.add
			@group_id = Group.add_group("Test Group", [@user.id, @other.id])
			@user.reload
			@group = Group.find(@group_id)
		end

		it "should update the fields if they are all filled out and valid" do
			post 'edit_group', { format: 'json', group: @group_id, 
				name: 'New Test Title', description: 'New testing description' }
			@group.reload
			@group.name.should eq 'New Test Title'
			@group.description.should eq 'New testing description'
		end

		it "should update the filled fields if some are ommitted" do
			post 'edit_group', { format: 'json', group: @group_id, name: 'New Test Title' }
			@group.reload
			@group.name.should eq 'New Test Title'
			@group.description.should eq ''
		end

		it "should fail if not a member" do
			new_user = User.new(name: "New User", email: "new@example.com",
				password: "test_password")
			new_user.add
			new_user_token = User.new_token
			new_user.update_attribute(:remember_token, User.hash(new_user_token))
			@request.cookies['current_user_token'] = new_user_token
			post 'edit_group', { format: 'json', group: @group_id, 
				name: 'New Test Title', description: 'New testing description' }
			JSON.parse(response.body)['err_code'].should eq ERR_INVALID_PERMISSIONS
			@group.reload
			@group.name.should eq 'Test Group'
			@group.description.should eq ''
		end

		describe "with invalid inputs" do
			describe " - name too long" do
				before { post 'edit_group', { format: 'json', group: @group_id,
					name: 'a' * 60 } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_NAME }
			end
			describe " - blank name" do
				before { post 'edit_group', { format: 'json', group: @group_id,
					name: '' } }
				specify { JSON.parse(response.body)['err_code'].should eq ERR_INVALID_NAME }
			end
		end
	end
end