class PosessionCharge < ApplicationRecord
	belongs_to :extra_charge
	belongs_to :business_unit
end
