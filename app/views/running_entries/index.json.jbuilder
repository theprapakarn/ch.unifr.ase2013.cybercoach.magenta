json.array!(@running_entries) do |running_entry|
  json.extract! running_entry, :course_length, :course_type, :number_of_round, :track
  json.url running_entry_url(running_entry, format: :json)
end
