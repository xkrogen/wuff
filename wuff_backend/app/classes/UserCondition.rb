# Class for storing User-type conditionals.

class UserCondition < Condition

	def initialize(cond_type, user_list) 
		@cond_type = cond_type
		@user_ids = user_list
		@cond_met = COND_NOT_MET
	end

	# Returns a hash representing this Condition. When computing the user list,
	# ignores invalid user IDs.
	def get_hash
		user_list = {}
		user_count = 0
		@user_ids.each do |user_id|
			begin
				user = User.find(user_id)
			rescue ActiveRecord::RecordNotFound
				next
			end
			user_count += 1
			user_list[user_count] = { name: user.name, email: user.email }
		end
		user_list[:user_count] = user_count
		return { cond_type: @cond_type, cond_met: @cond_met, user_list: user_list, id_list: @user_ids }
	end

	# Return a list of users for condition literal
	def get_user_list
		return @user_id
	end

end
