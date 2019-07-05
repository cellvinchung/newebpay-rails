require 'newebpay/attr_key_helper'
require 'http'

module Newebpay
	class CloseFund
		include AttrKeyHelper
		# REQUIRED_ATTRS = %w(TimeStamp Version RespondType).freeze
		attr_reader :result, :status, :message
		def initialize(options)
			raise ArgumentError, "When initializing #{self.class.name}, you must pass a hash as an argument." unless options.is_a? Hash
			raise ArgumentError, 'Missing required argument: price.' unless options[:price]
	    	raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]
	    	raise ArgumentError, 'Missing required argument: close_type.' unless options[:close_type]
	    	raise ArgumentError, 'close_type should be :request or :refund.' if [:request, :refund].exclude?(options[:close_type].to_sym)
	    	merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
	      	@attrs = options.except(:price, :order_number, :number_type, :merchant_id, :abort, :close_type)

	      	@attrs["Amt"] = options[:price].to_s
	      	@attrs["IndexType"] = options[:number_type] || "1"
	      	@attrs["Cancel"] = "1" if options[:abort]

		    case @attrs["IndexType"].to_s 
		    when "1"
		    	@attrs["MerchantOrderNo"] = options[:order_number].to_s
		    when "2"
		    	@attrs["TradeNo"] = options[:order_number].to_s
		    else
		    	raise ArgumentError, 'number_type should be 1 or 2.'
		    end

	      	case options[:close_type].to_sym
	      	when :request
	      		@attrs["CloseType"] = "1"
	      	when :refund
	      		@attrs["CloseType"] = "2"
	      	end

	      	@attrs['Version'] = version
	      	@attrs['TimeStamp'] = Time.current.to_i
	      	@attrs['RespondType'] = "JSON"

	      	@format_attrs = {}
	        @format_attrs["MerchantID_"] = merchant_id
	        @format_attrs["PostData_"] = Newebpay::NewebpayHelper.encrypt_data(URI.encode_www_form(@attrs))

	        response = JSON.parse(HTTP.post(Newebpay.config.close_fund_url, form: @format_attrs).body.to_s)
	        @status = response["Status"]
	        @message = response["Message"]
	        result = response["Result"]

	        @result = Result.new(result)
		end
		
		def success?
		    @status && @status == 'SUCCESS'
		end

	      def set_attr(name, value)
	        @attrs[name] = value
	      end

	      def sorted_attrs
	        @attrs.sort
	      end

	      def to_s
	        sorted_attrs.map { |k, v| "#{k}=#{v}" }.join('&')
	      end
		def version
	        "1.1"
	    end
		class Result 
	      	include AttrKeyHelper
		    def initialize(data)
		        @data = data
		    end

		      private

		      def method_missing(method_name, *args)
		        data_key = data_key_for(method_name)
		        if data_key
		          @data[data_key]
		        else
		          super
		        end
		      end

		      def respond_to_missing?(method_name, _include_private = false)
		        !data_key_for(method_name).nil?
		      end

		      def data_key_for(name)
		        possible_data_keys_for(name).find { |k| @data.key?(k) }
		      end

		      def possible_data_keys_for(key)
		        [key.to_s, convert_to_attr_key(key)]
		      end
	    end
	end
end