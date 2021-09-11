Rails.application.routes.draw do
  devise_for :users

  root to: 'trainings#index'

  resources :exercise_name_vocs

  resources :trainings do
    # Вложенный ресурс упражнений
    resources :exercises, only: [:create, :destroy, :update, :edit]
    collection do
      get :download_textfile
      get :instruction
    end
  end

  resources :users, only: [:show, :edit, :update, :destroy]

  resources :statistics, only: [:show] do
    collection do
      get :stat
      post :stat
    end
  end
end
