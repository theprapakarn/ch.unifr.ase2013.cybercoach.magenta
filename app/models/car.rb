class Car < ActiveRecord::Base
  belongs_to :user
  has_many :bids, dependent: :destroy
  validates :user_id, presence: true
  default_scope -> { order('created_at DESC') }
end
