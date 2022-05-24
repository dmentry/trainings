class UsersController < ApplicationController
  before_action :set_user, except: %i[index]
  before_action :authenticate_user!
  before_action :user_admin?, only: %i[index admin_login_as_user]

  def index
    @users = User.all

    @data = []

    @users.each do |user|
      user_operator = IpFinderHelper.ip_address(user.current_sign_in_ip)

      if user_operator.empty?
        user_data = '-'
      else  
        user_data = "#{user_operator[:country]}, #{user_operator[:regionName]}, #{user_operator[:city]}, #{user_operator[:isp]}"
      end

      if user.current_sign_in_at.present?
        td = user.current_sign_in_at
      else
        td = Time.new(1, 1, 1, 1, 0, 0, 0)
      end

      @data << [user, td, user_data]
    end

    @data = @data.sort_by{ |h| h.second }.reverse
  end

  def show
  end

  def edit
  end

  def update
    unless current_user.name == 'guest'
      if @user.update(user_params)
        redirect_to @user, notice: "Данные были успешно обновлены."
      else
        render :edit
      end
    else
      redirect_to @user, alarm: "Вам такое нельзя."
    end
  end

  def destroy
    unless current_user.name == 'guest'
      @user.destroy
        redirect_to users_url, notice: "Пользователь был удален."
    else
      redirect_to @user, alarm: "Вам такое нельзя."
    end
  end

  def achivements
  end

  def admin_login_as_user
    user = User.find(params[:id])

    sign_in(:user, user, { :bypass => true })

    redirect_to root_path
  end

  private

  def set_user
    current_user.admin ? @user = User.find(params[:id]) : @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
