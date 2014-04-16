# Class for storing number-type conditionals, i.e. COND_NUM_USERS

class NumberCondition < Condition

	def initialize(num_users) 
		@num_users = num_users
		@cond_met = COND_NOT_MET
	end

	# Returns a hash representing this Condition.
	def get_hash
		return { cond_type: COND_NUM_ATTENDING, 
			cond_met: @cond_met, num_users: @num_users }
	end

	# Overload Condition#type since it will always be the same type.
	def type
		COND_NUM_ATTENDING
	end

end


