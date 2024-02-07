class ExtraCharge < ApplicationRecord
	has_many :extra_development_charges
	has_many :posession_charges
end
