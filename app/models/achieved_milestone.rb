class AchievedMilestone < ApplicationRecord
	belongs_to :payment_milestone
	belongs_to :block
end
