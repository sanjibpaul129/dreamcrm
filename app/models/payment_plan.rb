class PaymentPlan < ApplicationRecord
	belongs_to :block
	belongs_to :business_unit
	has_many :milestones

def construction_linked_milestones
	block_level=Milestone.includes(:payment_milestone).where(:payment_milestones => {block_level: true}, :milestones => {payment_plan_id: self.id})
	floor_level=Milestone.includes(:payment_milestone).where(:payment_milestones => {floor_level: true}, :milestones => {payment_plan_id: self.id})
	construction_linked=block_level+floor_level
	return construction_linked
end

end
