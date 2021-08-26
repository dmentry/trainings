class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(Rails.env.to_sym, :mail, :default_from)

  EMAIL_TO = Rails.application.credentials.dig(Rails.env.to_sym, :mail, :default_to)

  layout 'mailer'
end
