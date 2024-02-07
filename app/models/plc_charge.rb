class PlcCharge < ApplicationRecord
	belongs_to :block
	belongs_to :plc
	belongs_to :organisation
end
