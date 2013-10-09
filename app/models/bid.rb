class Bid < ActiveRecord::Base
  belongs_to :user
  belongs_to :car
  validates :car_id, presence: true
  validates :user_id, presence: true
  validates_numericality_of :price, greater_than: ->(bid) { bid.car.bids.last.price },
                            only_integer: true, allow_blank: false
end
