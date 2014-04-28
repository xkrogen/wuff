class AddSchedulerJobIdToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :scheduler_job_id, :integer
  end
end
