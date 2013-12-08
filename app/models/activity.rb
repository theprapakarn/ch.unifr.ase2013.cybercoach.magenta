class Activity < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  belongs_to :sport
  belongs_to :reference_activity,
             class_name: "Activity",
             foreign_key: "reference_activity_id"
end
