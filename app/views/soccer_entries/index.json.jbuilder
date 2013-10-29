json.array!(@soccer_entries) do |soccer_entry|
  json.extract! soccer_entry, 
  json.url soccer_entry_url(soccer_entry, format: :json)
end
