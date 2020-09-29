Newebpay::Engine.routes.draw do
	match :build, action: :new, via: [:get, :post]


	match 'mpg_callbacks', to: 'mpg_callbacks#proceed', via: [:get, :post]
	match 'payment_code_callbacks', to: 'payment_code_callbacks#proceed', via: [:get, :post]
	match 'notify_callbacks', to: 'notify_callbacks#proceed', via: [:get, :post]

	match 'periodical_callbacks', to: 'periodical_callbacks#proceed', via: [:get, :post]
	match 'periodical_notify_callbacks', to: 'periodical_notify_callbacks#proceed', via: [:get, :post]

	match 'donation_callbacks', to: 'donation_callbacks#proceed', via: [:get, :post]
	match 'donation_notify_callbacks', to: 'donation_notify_callbacks#proceed', via: [:get, :post]

	match 'cancel_auth_notify_callbacks', to: 'cancel_auth_notify_callbacks#proceed', via: [:get, :post]
end