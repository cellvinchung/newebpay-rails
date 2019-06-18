require 'newebpay/attr_key_helper'
require 'http'

module Newebpay
	class QueryTrade
		include AttrKeyHelper
		REQUIRED_ATTRS = %w(TimeStamp Version MerchantOrderNo RespondType).freeze
		attr_reader :result, :status
		def initialize(attrs)
	        unless attrs.is_a? Hash
	          raise ArgumentError, "When initializing #{self.class.name}, you must pass a hash as an argument."
	        end

	        @attrs = {}
	        missing_attrs = REQUIRED_ATTRS.map(&:clone)

	        attrs.each_pair do |k, v|
	          key = k.to_s
	          value = v.to_s
	          missing_attrs.delete(key)
	          @attrs[key] = value
	        end
	        
	        if @attrs['Version'].nil?
	          @attrs['Version'] = version
	          missing_attrs.delete('Version')
	        end

	        if @attrs['TimeStamp'].nil?
	          @attrs['TimeStamp'] = Time.now.to_i
	          missing_attrs.delete('TimeStamp')
	        end
	        if @attrs['RespondType'].nil?
	          @attrs['RespondType'] = "JSON"
	          missing_attrs.delete('RespondType')
	        end
	        @attrs['CheckValue'] = check_value

	        raise ArgumentError, "The required attrs: #{missing_attrs.map { |s| "'#{s}'" }.join(', ')} #{missing_attrs.count > 1 ? 'are' : 'is'} missing." unless missing_attrs.count.zero?

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