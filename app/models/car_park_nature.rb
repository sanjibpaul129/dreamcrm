class CarParkNature < ApplicationRecord
	has_many :car_parks
	has_many :cost_sheet_car_parkings
end
