class ApplicationController < ActionController::Base
  # переключение локалей
    # before_action :switch_locale
  # передача параметра текущей локали через запросы
  # def default_url_options
  #   {locale: I18n.locale}
  # end

  # Позволяем использовать возможности пандита во всех контроллерах
  # include Pundit
  
  # Обработать ошибку авторизации
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # private

  # def switch_locale(&action)
  #   locale = params[:locale] || I18n.default_locale
  #   I18n.locale = locale
  # end

  # def user_not_authorized
  #   # Перенаправляем юзера откуда пришел (или в корень сайта) с сообщением об ошибке
  #   flash[:alert] = 'Только для админа!'

  #   redirect_to(request.referrer || root_path)
  # end

  helper_method :user_avatar

  # Настройка для работы Девайза, когда юзер правит профиль
  before_action :configure_permitted_parameters, if: :devise_controller?

  def user_admin?
    redirect_to trainings_path, alert: "Вам сюда не надо!" unless current_user.admin
  end

  def user_avatar(user)
    if user.avatar?
      ActionController::Base.helpers.image_tag(user.avatar.thumb.url, class: 'user_avatar')
    else
      ActionController::Base.helpers.image_pack_tag('user.png', class: 'user_avatar')
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, :remember_me])
    devise_parameter_sanitizer.permit(:account_update, keys: [:password, :password_confirmation, :current_password])
  end
end
