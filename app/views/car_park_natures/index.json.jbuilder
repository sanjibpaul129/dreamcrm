json.array!(@car_park_natures) do |car_park_nature|
  json.extract! car_park_nature, :id, :wheels, :description
  json.url car_park_nature_url(car_park_nature, format: :json)
end
