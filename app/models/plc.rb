class Plc < ApplicationRecord
	has_many :plc_charges
	belongs_to :organisation
end
