class UsersController < ApplicationController
  # before_action :set_user, only: %i[ show edit update destroy ]
  before_action :set_user, except: :index
  before_action :authenticate_user!

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Данные были успешно обновлены."
    else
      render :edit
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy
      redirect_to users_url, notice: "Пользователь был удален."
  end

  def achivements
    if Exercise.all.count <= 1
      redirect_to trainings_url, alert: "У вас еще недостаточно данных для статистики."
    else
      # @exercise_name_vocs ||= current_user.exercise_name_vocs.order(label: :asc).reject{ |exercise| exercise.exp == 0 }

      # @exercise_name_vocs = @exercise_name_vocs.sort_by{ |e| e.exercises.last.level }.reverse!

      @exercise_name_vocs = StatisticsHelper.user_profile_stat(current_user)
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
    # @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
