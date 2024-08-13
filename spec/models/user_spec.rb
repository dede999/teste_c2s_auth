require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryBot.create(:user) }

  describe 'validations' do
    let(:new_user) { User.new email:  user.email }
    let(:blank_user) { User.new }
    let(:valid_user) { FactoryBot.build(:user) }

    it 'is invalid with repeated email' do
      expect(new_user).not_to be_valid
    end

    it 'is invalid with blank email' do
      expect(blank_user).not_to be_valid
    end

    it 'is valid with valid attributes' do
      expect(valid_user).to be_valid
    end
  end

  describe 'create_token' do
    result = nil
    let(:token) { 'user_token' }

    before do
      allow(JWT).to receive(:encode).and_return(token)
      result = user.create_token
    end

    it 'returns a token' do
      expect(result).to eq(token)
    end

    it 'is expected to call JWT.encode' do
      expect(JWT).to have_received(:encode)
    end
  end

  describe 'valid_password?' do
    before do
      allow(User).to receive(:decrypt_password_ciphertext).and_return('right')
    end

    %w[wrong right].each do |password|
      context "when password is #{password}" do
        it "is expected to have returned #{password == 'right'}" do
          expect(user.valid_password?(password)).to eq(password == 'right')
        end

        it 'is expected to have decrypted password' do
          user.valid_password?(password)
          expect(User).to have_received(:decrypt_password_ciphertext).with(user.password_ciphertext)
        end
      end
    end
  end
end
