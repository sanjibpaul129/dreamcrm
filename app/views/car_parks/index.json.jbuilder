json.array!(@car_parks) do |car_park|
  json.extract! car_park, :id, :nature_id, :rate, :block_id, :date
  json.url car_park_url(car_park, format: :json)
end
