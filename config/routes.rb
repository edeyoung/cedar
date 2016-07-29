Rails.application.routes.draw do
  devise_for :users

  get 'validations', to: 'validations#index'
  post 'validations/:id/add_tag', to: 'validations#add_tag'
  post 'validations/:id/remove_tag', to: 'validations#remove_tag'

  get 'measures', to: 'measures#index'
  post 'measures/:id/add_tag', to: 'measures#add_tag'
  post 'measures/:id/remove_tag', to: 'measures#remove_tag'

  get 'test_executions/:id/qrda_progress', to: 'test_executions#qrda_progress'
  post 'test_executions/with_time_range', to: 'test_executions#with_time_range'

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
