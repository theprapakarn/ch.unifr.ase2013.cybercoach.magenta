class User < ActiveRecord::Base
  before_save { self.username = username }
  before_create :create_remember_token
  has_secure_password
  has_many :cars

def User.new_remember_token
  SecureRandom.urlsafe_base64
end

def User.encrypt(token)
  Digest::SHA1.hexdigest(token.to_s)
end

def create_remember_token
  self.remember_token = User.encrypt(User.new_remember_token)
end
end
