json.array!(@cars) do |car|
  json.extract! car, :model, :brand
  json.url car_url(car, format: :json)
end
