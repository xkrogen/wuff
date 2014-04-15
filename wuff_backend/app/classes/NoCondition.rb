# Class for storing empty conditionals.

class NoCondition < Condition

	def initialize
		@cond_met = COND_NOT_MET
	end

	# Overload Condition#met since a NoCondition can never be met.
	def met
		raise "Attempted to mark a NoCondition as met."
	end

	# Returns a hash representing this Condition.
	def get_hash
		{ cond_type: COND_NONE }
	end

end
