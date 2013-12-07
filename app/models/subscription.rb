class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :sport
  belongs_to :participant
  belongs_to :partnership
  has_many :entries

  def sport=(sport)
    @sport = sport
  end

  def sport
    if @sport == nil
      super
    else
      @sport
    end
  end

  def self.save(save_info)
    if self.is_proxy
      super(save_info)
    else
      SubscriptionsHelper.save_cy_ber_coach(self)
      super(save_info)
    end
  end

  def save
    if self.is_proxy
      if Subscription.find_by(reference: self.reference) == nil
        super
      end
    else
      SubscriptionsHelper.save_cy_ber_coach(self)
      if Subscription.find_by(reference: self.reference) == nil
        super
      end
    end
  end
end


