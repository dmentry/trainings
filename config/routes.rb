Rails.application.routes.draw do
  # devise_for :users

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
  root to: 'trainings#index'

  resources :exercise_name_vocs
  resources :trainings do
    # Вложенный ресурс упражнений
    resources :exercises, only: [:create, :destroy]  
  end

  resources :users, only: [:show, :edit, :update, :destroy]
end
end
