class MaintainenceCharge < ApplicationRecord
	belongs_to :business_unit
	belongs_to :company
end
