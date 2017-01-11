Rails.application.routes.draw do
  apipie
  devise_for :users

  get 'validations/:id', to: 'validations#show'
  get 'validations', to: 'validations#index'

  post 'validations/:id/add_tag', to: 'validations#add_tag'
  post 'validations/:id/remove_tag', to: 'validations#remove_tag'

  get 'measures', to: 'measures#show'
  get 'measures', to: 'measures#index'
  post 'measures/:id/add_tag', to: 'measures#add_tag'
  post 'measures/:id/remove_tag', to: 'measures#remove_tag'

  get '/test_executions', to: 'test_executions#show'
  delete '/test_executions', to: 'test_executions#destroy'
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

  namespace :api do
    namespace :v1, defaults: { format: 'json' } do
      devise_for :users, controllers: { sessions: 'api/v1/sessions', registrations: 'api/v1/registrations' }
      devise_scope :users do
        get 'login' => 'users/sessions#new'
      end
      resources :validations #, only: [:index, :show], defaults: { format: 'json' }
      resources :measures, only: [:index, :show]
      resources :test_executions, only: [:index, :create, :show, :update, :destroy] do
        resources :documents, only: [:index, :show, :update] do
          match :report_results, via: [:patch], on: :collection
        end
      end
    end
  end
end
