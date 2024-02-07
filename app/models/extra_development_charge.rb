class ExtraDevelopmentCharge < ApplicationRecord
	belongs_to :extra_charge
	belongs_to :business_unit
	belongs_to :block
end
