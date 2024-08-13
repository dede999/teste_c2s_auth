require 'rails_helper'

RSpec.describe "Accesses", type: :request do
  let(:user) { FactoryBot.create(:user) }
  after(:all) do
    User.destroy_all
  end

  describe "POST /sign_in" do
    context 'when user exists' do
      it 'returns http accepted' do
        post '/sign_in', params: { user: { email: user.email, password: 'MyString' } }
        expect(response).to have_http_status(:accepted)
      end
    end

    context 'when user does not exist' do
      it 'returns http unauthorized' do
        post '/sign_in', params: { user: { email: 'wrong_email', password: 'password' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when password is wrong' do
      it 'returns http unauthorized' do
        post '/sign_in', params: { user: { email: user.email, password: 'wrong_password' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /sign_up" do
    context 'when the given email is new' do
      it 'returns http created' do
        post '/sign_up', params: { user: { email: 'email_123@mail.com', password: 'password' } }
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the given email is already taken' do
      it 'returns http unprocessable_entity' do
        post '/sign_up', params: { user: { email: user.email, password: 'password' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /validate_token" do
    let(:token) { user.create_token }
    let(:invalid_token) { 'invalid_token' }
    let(:expired_token) do
      JWT.encode({
        user_id: user.id, expiration_date: Time.now - 3.hours
      }, ENV['JWT_SECRET'], 'HS256')
    end

    context 'when token is valid' do
      it 'returns http success' do
        get '/validate_token', headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['message']).to eq('Token is valid')
      end
    end

    context 'when token has expired' do
      it 'returns http unauthorized' do
        get '/validate_token', headers: { 'Authorization' => "Bearer #{expired_token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Token has expired')
      end
    end

    context 'when token is invalid' do
      it 'returns http unauthorized' do
        get '/validate_token', headers: { 'Authorization' => "Bearer #{invalid_token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Invalid token')
      end
    end
  end

end
