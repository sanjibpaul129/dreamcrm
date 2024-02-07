class CostSheetCarParking < ApplicationRecord
	belongs_to :cost_sheet
	belongs_to :car_park_nature, foreign_key: :car_parking_nature_id
end
