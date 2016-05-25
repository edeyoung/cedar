Rails.application.routes.draw do
  devise_for :users
  resources :validations

  get 'test_executions/:id/qrda_progress', to: 'test_executions#qrda_progress'

  resources :test_executions do
    member do
      post :copy
    end
    resources :steps, controller: 'test_executions/steps'
  end

  get '/about', to: 'static_pages#about'
  get '/feedback', to: 'static_pages#feedback'
  get '/help', to: 'static_pages#help'

  root to: 'test_executions#dashboard'
end
