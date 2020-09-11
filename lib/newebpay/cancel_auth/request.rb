# frozen_string_literal: true

module Newebpay::CancelAuth
  class Request
    attr_accessor :attrs, :merchant_id
    REQUIRED_ATTRS = %i[order_number price].freeze

    def initialize(options)
      check_valid(options)
      @attrs = {}
      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
      parse_attr(options)

      @attrs['Version'] = version
      @attrs['TimeStamp'] = Time.now.to_i
      @attrs['RespondType'] = 'JSON'

      result = HTTP.post(Newebpay.config.cancel_auth_url, form: form_attrs).body.to_s

      instance_exec(Response.new(result), &Newebpay.config.cancel_auth_notify_callback)
    end

    def form_attrs
      @form_attrs ||= {
        MerchantID_: merchant_id,
        PostData_: trade_info
      }
    end

    def trade_info
      @trade_info ||= Newebpay::Helpers.create_trade_info(attrs)
    end

    def version
      '1.0'
    end

    private

    def parse_attr(options)
      attrs['Amt'] = options[:price]
      attrs['IndexType'] = options[:number_type] || '1'

      case attrs['IndexType'].to_s
      when '1'
        attrs['MerchantOrderNo'] = options[:order_number]
      when '2'
        attrs['TradeNo'] = options[:order_number]
      else
        raise ArgumentError, "Invalid number_type: #{options[:number_type]}"
      end
    end

    def check_valid(options)
      unless options.is_a? Hash
        raise ArgumentError, "When initializing #{self.class.name}, you must pass a hash."
      end

      REQUIRED_ATTRS.each do |argument|
        raise ArgumentError, "Missing required argument: #{argument}." unless options[argument]
      end
    end
  end
end
