Rails.application.routes.draw do
  get 'health_check/check'
  root 'health_check#check'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
