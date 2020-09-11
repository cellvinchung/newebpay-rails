# frozen_string_literal: true

module Newebpay::QueryTrade
  class Search
    REQUIRED_ATTRS = %i[order_number price].freeze
    SLICE_ATTRS = %w[Amt MerchantID MerchantOrderNo]
    attr_accessor :attrs, :merchant_id, :response
    def initialize(options)
      check_valid(options)
      @attrs = {}
      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
      parse_attr(options)
    end

    def call
      result = HTTP.post(Newebpay.config.query_trade_url, form: attrs).body.to_s
      @response = Response.new(result)
    end

    def check_value
      @check_value ||= Newebpay::Helpers.query_check_value(attrs.slice(*SLICE_ATTRS))
    end

    def version
      '1.2'
    end

    private

    def parse_attr(options)
      @attrs['MerchantID'] = merchant_id
      @attrs['MerchantOrderNo'] = options[:order_number]
      @attrs['Amt'] = options[:price]
      @attrs['Version'] = version
      @attrs['TimeStamp'] = Time.now.to_i
      @attrs['RespondType'] = 'JSON'
      @attrs['CheckValue'] = check_value
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
