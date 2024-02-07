class PaymentMilestone < ApplicationRecord
	has_many :milestones
	has_many :time_based_milestones
end
