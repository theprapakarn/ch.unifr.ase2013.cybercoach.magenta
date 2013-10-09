class Bid < ActiveRecord::Base
  belongs_to :user
  belongs_to :car
  validates :car_id, presence: true
  validates :user_id, presence: true
  validates_numericality_of :price,
                            only_decimal: true,
                            allow_blank: false,
                            greater_than: ->(bid) { bid.car.price },
                            greater_than: ->(bid) {
                              if !bid.car.bids.last.nil?
                                bid.car.bids.last.price
                              else
                                0
                              end
                            }
end
