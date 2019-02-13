Rails.application.routes.draw do
  post '/report_webface_error', to: 'webface_error_report#report'
end
