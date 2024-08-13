class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true

  has_encrypted :password

  def create_token
    JWT.encode({
      user_id: id, expiration_date: Time.now + 2.hours
    }, ENV['JWT_SECRET'], 'HS256')
  end

  def valid_password?(password)
    User.decrypt_password_ciphertext(password_ciphertext) == password
  end
end
