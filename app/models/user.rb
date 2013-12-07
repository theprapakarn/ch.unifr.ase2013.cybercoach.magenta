class User < ActiveRecord::Base
  before_save { self.username = username }
  before_create :create_remember_token
  has_secure_password
  has_many :cars
  has_many :participants
  has_many :partnerships
  has_many :subscriptions
  has_many :entries
  has_many :activities

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end

  def save(save_info)
    SubscriptionsHelper.save_or_update_cy_ber_coach(self)
    super(save_info)
  end

  def save
    super
    UsersHelper.save_or_update_cy_ber_coach(self)
    super
  end


end
