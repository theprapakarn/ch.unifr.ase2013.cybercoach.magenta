json.array!(@participants) do |participant|
  json.extract! participant, :reference, :publicvisible, :user_id
  json.url participant_url(participant, format: :json)
end
