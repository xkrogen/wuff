# Some of the earlier events created in the database didn't have a 
# condition field in their party list, which can cause errors
# when some methods expect there to be a condition field. 

class AddConditionFieldsToOldEventPartyLists < ActiveRecord::Migration
  def change
  	Event.find_each do |event|
			curr_party_list = event.party_list

			party_list_modified = false
			new_party_list = curr_party_list.each_with_object({}) do |(uid, v), h| 
				if not v.has_key?(:condition)
					h[uid] = { status: v[:status], condition: { cond_type: 0, cond_met: 0 } }
					party_list_modified = true
				else 
					h[uid] = v
				end
			end
			if party_list_modified
				event.update_attribute(:party_list, new_party_list)
			end
  	end
  end
end
