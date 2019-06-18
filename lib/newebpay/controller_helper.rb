module Newebpay
	module ControllerHelper
		def query_trade_info(options)
	      raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]
	      raise ArgumentError, 'Missing required argument: price.' unless options[:price]
	      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
	      attributes = options.except(:price, :order_number, :merchant_id)
	      attributes[:MerchantID] = @merchant_id
	      attributes[:Amt] = options[:price]
	      attributes[:MerchantOrderNo] = options[:order_number]
	      Newebpay::QueryTrade.new(attributes)
	    end
	    def cancel_auth(options)
	    	raise ArgumentError, 'Missing required argument: price.' unless options[:price]
	    	raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]
	    	raise ArgumentError, 'Missing required argument: number_type.' unless options[:number_type]

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
	    def close_fund(options)
	    	raise ArgumentError, 'Missing required argument: price.' unless options[:price]
	    	raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]
	    	raise ArgumentError, 'Missing required argument: number_type.' unless options[:number_type]
	    	raise ArgumentError, 'Missing required argument: close_type.' unless options[:close_type]

	    	@merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
	      	attributes = options.except(:price, :order_number, :number_type, :merchant_id, :abort, :close_type)

	      	attributes[:MerchantID] = @merchant_id
	      	attributes[:Amt] = options[:price].to_s
	      	attributes[:IndexType] = options[:number_type] || "1"

	      	attributes[:Cancel] = "1" if options[:abort]

		    case attributes[:IndexType].to_s 
		    when "1"
		    	attributes[:MerchantOrderNo] = options[:order_number].to_s
		    when "2"
		    	attributes[:TradeNo] = options[:order_number].to_s
		    else
		    	raise ArgumentError, 'number_type should be 1 or 2.'
		    end

	      	case options[:close_type].to_sym
	      	when :request
	      		attributes[:CloseType] = "1"
	      	when :refund
	      		attributes[:CloseType] = "2"
	      	else
	      		raise ArgumentError, 'close_type should be :request or :refund.'
	      	end

	      	Newebpay::CloseFund.new(attributes)
	    end
	    ActionController::Base.include(self)
	end
end