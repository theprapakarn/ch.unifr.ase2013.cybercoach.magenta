class Sport < ActiveRecord::Base
  has_one :subscription

  def self.all
    if super.length > 0
      super
    else
      SportsHelper.get_cy_ber_coach_sports
    end
  end
 end
