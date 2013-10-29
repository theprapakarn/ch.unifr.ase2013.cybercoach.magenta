json.array!(@sports) do |sport|
  json.extract! sport, :reference, :name
  json.url sport_url(sport, format: :json)
end
