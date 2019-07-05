require 'newebpay/attr_key_helper'
require 'http'

module Newebpay
	class QueryTrade
		include AttrKeyHelper
		attr_reader :result, :status
		def initialize(options)
	        raise ArgumentError, "When initializing #{self.class.name}, you must pass a hash as an argument." unless options.is_a? Hash
	        raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]
	      	raise ArgumentError, 'Missing required argument: price.' unless options[:price]
	      	merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
		    
		    @attrs = options.except(:price, :order_number, :merchant_id)

		    @attrs["MerchantID"] = merchant_id
		    @attrs["Amt"] = options[:price]
		    @attrs["MerchantOrderNo"] = options[:order_number]
		    @attrs["Version"] = version
		    @attrs["TimeStamp"] = Time.current.to_i
		    @attrs["RespondType"] = "JSON"
		    @attrs['CheckValue'] = check_value

		    response = JSON.parse(HTTP.post(Newebpay.config.query_trade_url, form: @attrs).body.to_s)
	        @status = response["Status"]

	        result = response["Result"]
	        @result = Result.new(result)
		end
	      def success?
		        @status && @status == 'SUCCESS'
		  end
		  def valid?
		  		@result&.valid?
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

	      def check_value
	        data = "Amt=#{@attrs['Amt']}&MerchantID=#{@attrs['MerchantID']}&MerchantOrderNo=#{@attrs['MerchantOrderNo']}"
	        Newebpay::NewebpayHelper.create_check_value(data)
	      end

	      alias CheckValue check_value

	      def version
	        "1.1"
	      end

      class Result 
      	include AttrKeyHelper
	    def initialize(data)
	        @data = data
	    end
      	def valid?
      		try(:check_code) == expected_check_code
      	end
      	def expected_check_code
	        data = "Amt=#{amt}&MerchantID=#{merchant_id}&MerchantOrderNo=#{merchant_order_no}&TradeNo=#{trade_no}"
	        Newebpay::NewebpayHelper.create_check_code(data)
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