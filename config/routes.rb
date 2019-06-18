Newebpay::Engine.routes.draw do
  post 'mpg_callbacks', to: 'mpg_callbacks#proceed'
  post 'payment_code_callbacks', to: 'payment_code_callbacks#proceed'
  post 'notify_callbacks', to: 'notify_callbacks#proceed'

  post 'periodical_callbacks', to: 'periodical_callbacks#proceed'
  post 'periodical_notify_callbacks', to: 'periodical_notify_callbacks#proceed'

  get 'donation_callbacks', to: 'donation_callbacks#proceed'
  post 'donation_notify_callbacks', to: 'donation_notify_callbacks#proceed'

  post 'cancel_auth_notify_callbacks', to: 'cancel_auth_notify_callbacks#proceed'
end