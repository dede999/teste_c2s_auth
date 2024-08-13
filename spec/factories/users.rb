FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email_user_#{n}@email.com" }
    password { "MyString" }
    password_ciphertext { "MyText" }
  end
end
