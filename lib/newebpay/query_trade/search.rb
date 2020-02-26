# frozen_string_literal: true

module Newebpay::QueryTrade
  class Search
    REQUIRED_ATTRS = %i[order_number price].freeze
    attr_accessor :attrs, :merchant_id, :response

    def initialize(options)
      check_valid(options)
      @attrs = {}
      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
      parse_attr(options)

      @attrs['Version'] = version
      @attrs['TimeStamp'] = Time.now.to_i
      @attrs['RespondType'] = 'JSON'
      @attrs['CheckValue'] = check_value

      result = HTTP.post(Newebpay.config.query_trade_url, form: attrs).body.to_s
      @response = Response.new(result)
    end

    def check_value
      @check_value ||= Newebpay::NewebpayHelper.create_check_value(check_value_raw)
    end

    def check_value_raw
      URI.encode_www_form(attrs.slice('Amt', 'MerchantID', 'MerchantOrderNo').sort)
    end

    def version
      '1.1'
    end

    private

    def parse_attr(options)
      attrs['MerchantID'] = merchant_id
      attrs['MerchantOrderNo'] = options[:order_number]
      attrs['Amt'] = options[:price]
    end

    def check_valid(options)
      unless options.is_a? Hash
        raise ArgumentError, "When initializing #{self.class.name}, you must pass a hash as an argument."
      end

      REQUIRED_ATTRS.each do |argument|
        raise ArgumentError, "Missing required argument: #{argument}." unless options[argument]
      end
    end
  end
end
