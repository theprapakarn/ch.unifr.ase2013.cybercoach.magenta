class Partnership < ActiveRecord::Base
  has_many :subscriptions
  has_many :participants_to_partnerships
  has_many :participants,
           :through => :participants_to_partnerships,
           :source => :participants

  belongs_to :first_participant,
           class_name: "Participant",
           foreign_key: "first_participant_id"
  belongs_to :second_participant, class_name: "Participant",
          foreign_key: "second_participant_id"

  def first_participant(first_participant)
    @first_participant = first_participant
  end

  def first_participant
    if @first_participant == nil
      super
    else
      @first_participant
    end
  end

  def second_participant(second_participant)
    @second_participant = second_participant
  end

  def second_participant
    if @second_participant == nil
      super
    else
      @second_participant
    end
  end

  def save()
    if self.is_proxy
      if Partnership.find_by(reference: self.reference) == nil
        super
      end
    else
      PartnershipsHelper.save_cy_ber_coach(self)
      if Partnership.find_by(reference: self.reference) == nil
        super
      end
    end
  end
end
