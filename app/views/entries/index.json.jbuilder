json.array!(@entries) do |entry|
  json.extract! entry, :reference, :public_visible, :user_id, :subscription_id, :comment, :entry_date, :entry_location, :is_proxy
  json.url entry_url(entry, format: :json)
end
