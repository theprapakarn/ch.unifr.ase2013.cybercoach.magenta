class Partnership < ActiveRecord::Base
  belongs_to :user
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

  def set_current_user(current_user)
    @current_user = current_user
  end

  def current_user
    @current_user
  end

  def save()
      PartnershipsHelper.save_cy_ber_coach(self)
      super
  end
end
