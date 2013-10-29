json.array!(@subscriptions) do |subscription|
  json.extract! subscription, :reference, :publicvisible, :sport_id, :user_id
  json.url subscription_url(subscription, format: :json)
end
