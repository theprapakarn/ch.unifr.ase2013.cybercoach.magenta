class Activity < ActiveRecord::Base
  has_many :participants, dependent: :destroy
  has_many :entries
  belongs_to :sport
  belongs_to :owner,
             class_name: "Participant",
              foreign_key: "owner_id"
end
