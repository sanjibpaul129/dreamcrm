class CallRecord < ApplicationRecord
	belongs_to :lead

def call_status
	if self.status==1
		return 'Call Made'
	elsif self.status==2
		return 'Call Received'
	elsif self.status==3
		return 'Call Missed'
	end
end 

end
