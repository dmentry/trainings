Rails.application.routes.draw do
  devise_for :users

  root to: 'trainings#index'

  resources :exercise_name_vocs

  resources :trainings do
    collection do
      get  :errors_page
      get  :copy_training
      get  :trainings_upload_new
      post :trainings_upload_post
      # match 'search' => 'trainings#searchingw', via: [:get, :post], as: :searchingw #запись для для соответствия нескольким методам сразу
      get  'searchingw', to: 'trainings#searchingw'
      post 'searchingw', to: 'trainings#searchingw'
    end
    # Вложенный ресурс упражнений
    resources :exercises, only: [:new, :create, :destroy, :update, :edit] do
      get :up
      get :down
    end
    collection do
      get :download_textfile
      get :instruction
      get :all_trainings
    end
  end

  # get 'searchingw', to: 'trainings#searchingw'

  resources :users do
    member do
      get :achivements
      get :admin_login_as_user
    end
  end

  resources :statistics, only: [:show] do
    collection do
      get  :main_stat
      post :main_stat
      get  :secondary_stat
    end
  end
end
