module Newebpay
	module ControllerHelper
		
	    def cancel_auth(options)
	    	raise ArgumentError, 'Missing required argument: price.' unless options[:price]
	    	raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]

	    	@merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
	      	attributes = options.except(:price, :order_number, :number_type, :merchant_id)

	      	attributes[:MerchantID] = @merchant_id
	      	attributes[:Amt] = options[:price].to_s
	      	attributes[:IndexType] = options[:number_type] || "1"

	      	case attributes[:IndexType].to_s 
		    when "1"
		    	attributes[:MerchantOrderNo] = options[:order_number].to_s
		    when "2"
		    	attributes[:TradeNo] = options[:order_number].to_s
		    else
		    	raise ArgumentError, 'number_type should be 1 or 2.'
		    end
		    
		    attributes[:NotifyURL] = Newebpay::Engine.routes.url_helpers.cancel_auth_notify_callbacks_url(host: request.host, port: request.port) if Newebpay.config.cancel_auth_notify_callback

	      	Newebpay::CancelAuth.new(attributes)
	    end
	    ActionController::Base.include(self)
	end
end