require 'rails_helper'

RSpec.describe "Accesses", type: :request do
  let(:user) { FactoryBot.build(:user) }

  describe "POST /sign_in" do
    let(:token) { 'token' }

    before do
      allow(User).to receive(:find_by).and_return(user)
      allow(user).to receive(:create_token).and_return(token)
    end

    [
      {
        valid_passwd: true,
        object: { message: 'User signed in successfully', token: 'token' },
        status: :accepted,
      },
      {
        valid_passwd: false,
        object: { message: 'Invalid email or password' },
        status: :unauthorized
      },
    ].each do |test_case|
      context "when password is #{test_case[:valid_passwd]}" do
        before do
          allow(user).to receive(:valid_password?).and_return(test_case[:valid_passwd])
          post '/sign_in', params: { user: { email: user.email, password: 'password' } }
        end

        it "is expected to return http status #{test_case[:status]}" do
          expect(response).to have_http_status(test_case[:status])
        end

        it "is expected to have looked for the user" do
          expect(User).to have_received(:find_by).with(email: user.email)
        end

        it "is expected to have checked the password" do
          expect(user).to have_received(:valid_password?).with('password')
        end

        it "is expected #{test_case[:valid_passwd] ? 'to': 'not to'} have created a token" do
          method = test_case[:valid_passwd] ? :to : :not_to
          expect(user).send(method, have_received(:create_token))
        end

        it "is expected to return the expected object" do
          expect(response.body).to eq(test_case[:object].to_json)
        end
      end
    end
  end

  describe "POST /sign_up" do
    before do
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive_message_chain(:errors, :full_messages).and_return([])
    end

    [true, false].each do |saved|
      context "when user is #{saved ? 'saved' : 'not saved'}" do
        before do
          allow(user).to receive(:save).and_return(saved)
          allow(user).to receive(:create_token).and_return('token')
          post '/sign_up', params: { user: { email: user.email, password: 'password' } }
        end

        it "is expected to return http status #{saved ? :created : :unprocessable_entity}" do
          expect(response).to have_http_status(saved ? :created : :unprocessable_entity)
        end

        it "is expected to have built the user" do
          expect(User).to have_received(:new)
        end

        it "is expected to have saved the user" do
          expect(user).to have_received(:save)
        end

        it "is expected #{saved ? 'to': 'not to'} have created a token" do
          method = saved ? :to : :not_to
          expect(user).send(method, have_received(:create_token))
        end

        it "is expected to return the expected object" do
          if saved
            expect(response.body).to eq({ message: 'User created successfully', token: 'token' }.
              to_json)
          else
            expect(response.body).to eq({ messages: [] }.to_json)
          end
        end
      end
    end
  end

  describe "GET /validate_token" do
    context "when token is valid" do
      [true, false].each do |expired|
        context "and #{expired ? 'is': 'is not'} expired" do
          before do
            allow(JWT).to receive(:decode).and_return(
              [
                {
                  'expiration_date' => expired ? Time.now - 1.hour : Time.now + 1.hour,
                  'user_id' => user.id,
                },
              ]
            )
            get "/validate_token", headers: { 'Authorization' => 'Bearer token' }
          end

          it "is expected to return http status #{expired ? :unauthorized : :ok}" do
            expect(response).to have_http_status(expired ? :unauthorized : :ok)
          end

          it "is expected to have returned the user id" do
            expect(JSON.parse(response.body)['user_id']).to eq(user.id)
          end

          it "is expected to have a corresponding rsponse message" do
            expect(JSON.parse(response.body)['message'])
              .to eq(expired ? 'Token has expired' : 'Token is valid')
          end
        end
      end
    end

    context "when token is invalid" do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::DecodeError)
        get "/validate_token", headers: { 'Authorization' => 'Bearer token' }
      end

      it "is expected to return http status :unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
