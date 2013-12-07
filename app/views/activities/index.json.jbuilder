json.array!(@activities) do |activity|
  json.extract! activity, :reference, :name, :user_id, :start_time, :end_time, :sport, :owner, :entry, :is_proxy
  json.url activity_url(activity, format: :json)
end
