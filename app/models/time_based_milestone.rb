class TimeBasedMilestone < ApplicationRecord
	belongs_to :payment_milestone, foreign_key: :previous_payment_milestone_id
end
