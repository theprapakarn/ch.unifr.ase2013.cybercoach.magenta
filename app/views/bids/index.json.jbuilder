json.array!(@bids) do |bid|
  json.extract! bid, :price, :price, :user_id
  json.url bid_url(bid, format: :json)
end
