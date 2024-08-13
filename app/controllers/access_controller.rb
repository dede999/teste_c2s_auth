class AccessController < ApplicationController
  def sign_in
    req_params = user_params
    @user = User.find_by(email: req_params[:email])
    if @user&.valid_password?(req_params[:password])
      token = @user.create_token
      render json: { message: 'User signed in successfully', token: token }, status: :accepted
    else
      render json: { message: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def sign_up
    @user = User.new(user_params)
    if @user.save
      token = @user.create_token
      render json: { message: 'User created successfully', token: token }, status: :created
    else
      render json: { messages: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def validate_token
    token = request.headers['Authorization'].split(' ').last

    begin
      decoded_token = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: 'HS256' })
      check_token_expiration(decoded_token)
    rescue JWT::DecodeError
      render json: { message: 'Invalid token' }, status: :unauthorized
      return
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def check_token_expiration(decoded_token)
    puts decoded_token[0]['expiration_date']
    puts Time.now
    puts decoded_token[0]['expiration_date'] > Time.now
    if decoded_token[0]['expiration_date'] > Time.now
      render json: { message: 'Token is valid', user_id: decoded_token[0]['user_id'] }, status: :ok
    else
      render json: { message: 'Token has expired' }, status: :unauthorized
    end
  end
end
