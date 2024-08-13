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
end
