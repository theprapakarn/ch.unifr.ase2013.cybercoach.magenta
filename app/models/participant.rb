class Participant < ActiveRecord::Base
  belongs_to :user
  has_many :subscriptions
  has_many :participants_to_partnerships
  has_many :partnerships,
           :through => :participants_to_partnerships,
           :source => :partnerships
end
