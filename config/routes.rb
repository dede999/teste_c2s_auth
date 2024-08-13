Rails.application.routes.draw do
  post '/sign_in', to: 'access#sign_in'
  post '/sign_up', to: 'access#sign_up'
  get '/validate_token', to: 'access#validate_token'

  get 'health_check/check'
  root 'health_check#check'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
