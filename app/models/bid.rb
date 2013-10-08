class Bid < ActiveRecord::Base
  belongs_to :user
  belongs_to :car
  validates :car_id, presence: true
  validates :user_id, presence: true
  validates :price, numericality: { only_integer: true, allow_blank: true }
end
