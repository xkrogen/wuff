
class NotifyHandler
	@job_mapping = {}
	@task_scheduler = Rufus::Scheduler.new

	def self.task_scheduler
		@task_scheduler
	end

	# Callback for the task scheduler. Takes in a job, which it uses 
	# to find the corresponding event, which it then notifies. 
	def self.call(job)
		begin 
			event = Event.find(@job_mapping[job.id])
		rescue ActiveRecord::RecordNotFound
			puts "ERROR: Attempt to notify #{@job_mapping[job.id]} failed."
			return
		end
		puts "Notifying #{event.id} (#{event.name}) of starting soon."
		event.notify_starting
	end

	# Adds a mapping from job_id to event_id, such that when job_id
	# is called, NotifyHandler will know to notify event_id.
	def self.add_job_mapping(job_id, event_id)
		@job_mapping[job_id] = event_id
	end
end