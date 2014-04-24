
# Class to store a Condition. Superclass for the specific types of 
# Conditions; shouldn't be initialized directly.

class Condition
	
	# Method to create a condition object from a hash that was created
	# using condition.get_hash. Used to recreate Condition objects 
	# extracted from the database in hash format. 
	# Returns nil if the hash is malformed. 
	def self.create_from_hash(hash)
		return nil if not (hash.has_key?(:cond_type) && hash.has_key?(:cond_met))
		case hash[:cond_type]
		when COND_NONE
			return NoCondition.new
		when COND_NUM_ATTENDING
			return nil if not (hash.has_key?(:num_users))
			return NumberCondition.new(hash[:num_users])
		when COND_USER_ATTENDING_ANY, COND_USER_ATTENDING_ALL
			return nil if not (hash.has_key?(:id_list))
			return UserCondition.new(hash[:cond_type], hash[:id_list])
		end
	end

	# Dummy method. Shouldn't try to get the hash of a Condition.
	def get_hash
		{}
	end

	# Return the type of Condition.
	def type
		@cond_type
	end

	# Mark this condition as met.
	def met
		@cond_met = COND_MET
	end

	# Mark this condition as not met. 
	def unmet
		@cond_met = COND_NOT_MET
	end

	# Returns true if this condition is met. False otherwise. 
	def met?
		@cond_met == COND_MET
	end
end


