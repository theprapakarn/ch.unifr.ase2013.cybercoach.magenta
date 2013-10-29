json.array!(@partnerships) do |partnership|
  json.extract! partnership, :reference, :public_visible, :first_user_id, :second_user_id, :first_user_confirmed, :second_user_confirmed, :datecreated
  json.url partnership_url(partnership, format: :json)
end
