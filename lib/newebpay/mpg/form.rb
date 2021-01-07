# frozen_string_literal: true

module Newebpay::MPG
  class Form
    attr_accessor :attrs, :merchant_id
    REQUIRED_ATTRS = %i[order_number description price email payment_methods].freeze
    PAYMENT_METHODS = %i[credit credit_red unionpay webatm vacc cvs barcode android_pay samsung_pay p2g].freeze
    def initialize(options)
      check_valid(options)
      @attrs = {}
      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
      parse_attr(options)

      @attrs['Version'] = version
      @attrs['TimeStamp'] = Time.now.to_i
      @attrs['RespondType'] = 'JSON'
    end

    def form_attrs
      @form_attrs ||= {
        MerchantID: merchant_id,
        TradeInfo: trade_info,
        TradeSha: trade_sha,
        Version: version
      }
    end

    def trade_info
      @trade_info ||= Newebpay::NewebpayHelper.encrypt_data(encode_url_params)
    end

    def trade_sha
      @trade_sha ||= Newebpay::NewebpayHelper.sha256_encode_trade_info(trade_info)
    end

    def encode_url_params
      URI.encode_www_form(attrs)
    end

    def version
      '1.5'
    end

    private

    def parse_attr(options)
      attrs[:MerchantID] = merchant_id
      attrs[:MerchantOrderNo] = options[:order_number]
      attrs[:ItemDesc] = options[:description]
      attrs[:Amt] = options[:price]
      attrs[:Email] = options[:email]
      attrs[:CVSCOM] = options[:cvscom]
      attrs[:LoginType] = options[:login_required] ? '1' : '0'
      attrs[:LangType] = options[:locale] || 'zh-tw'
      attrs[:TradeLimit] = options[:trade_limit]
      attrs[:ExpireDate] = options[:expire_date]
      attrs[:ClientBackURL] = options[:cancel_url]
      attrs[:OrderComment] = options[:comment]
      attrs[:EmailModify] = options[:email_editable] ? '1' : '0'
      attrs[:InstFlag] = options[:inst_flag]
      attrs[:ReturnURL] = Newebpay::Engine.routes.url_helpers.mpg_callbacks_url(host: Newebpay.host, protocol: Newebpay.protocol)
      attrs[:CustomerURL] = Newebpay::Engine.routes.url_helpers.payment_code_callbacks_url(host: Newebpay.host, protocol: Newebpay.protocol) if Newebpay.config.payment_code_callback
      attrs[:NotifyURL] = Newebpay::Engine.routes.url_helpers.notify_callbacks_url(host: Newebpay.host, protocol: Newebpay.protocol) if Newebpay.config.notify_callback

      options[:payment_methods].each do |payment_method|
        if payment_method == :credit_red
          attrs[:CreditRed] = '1'
        else
          attrs[payment_method.upcase] = '1'
        end
      end
    end

    def check_valid(options)
      unless options.is_a? Hash
        raise ArgumentError, "When initializing #{self.class.name}, you must pass a hash."
      end

      REQUIRED_ATTRS.each do |argument|
        raise ArgumentError, "Missing required argument: #{argument}." unless options[argument]
      end

      unless options[:payment_methods].is_a? Array
        raise ArgumentError, 'payment_methods must be an Array'
      end

      if (options[:payment_methods] - PAYMENT_METHODS).any?
        raise ArgumentError, 'Invalid payment method'
      end
    end
  end
end
