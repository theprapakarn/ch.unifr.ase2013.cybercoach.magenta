class ParticipantsToPartnership < ActiveRecord::Base
  belongs_to :participants,
             class_name: "Participant",
             foreign_key: "participant_id"
  belongs_to :partnerships,
             class_name: "Partnership",
             foreign_key: "partnership_id"
end
