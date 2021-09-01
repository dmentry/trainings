Rails.application.routes.draw do
  # devise_for :users
  root to: 'trainings#index'

  resources :exercise_name_vocs
  resources :trainings do
    # Вложенный ресурс упражнений
    resources :exercises, only: [:create, :destroy, :update, :edit]  
  end

  resources :users, only: [:show, :edit, :update, :destroy]

  resources :statistics, only: [:index]
end
