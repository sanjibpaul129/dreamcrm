class PreferredLocationTag < ApplicationRecord
	belongs_to :preferred_location
	belongs_to :lead
end
