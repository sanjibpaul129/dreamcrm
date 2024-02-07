class AccessPointPersonnel < ApplicationRecord
	belongs_to :access_point
	belongs_to :personnel
end
