# frozen_string_literal: true

require 'newebpay/attr_key_helper'

module Newebpay::Periodical
  class Form
    REQUIRED_ATTRS = %i[order_number description price email].freeze
    attr_accessor :attrs, :merchant_id
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
      attrs[:MerOrderNo] = options[:order_number]
      attrs[:ProdDesc] = options[:description]
      attrs[:PeriodAmt] = options[:price]
      attrs[:PayerEmail] = options[:email]
      attrs[:PeriodPoint] = options[:period_point] || '01'
      attrs[:PeriodTimes] = options[:period_times] || '99'
      attrs[:PeriodStartType] = options[:check_type] || '1'
      attrs[:MerchantID] = merchant_id
      attrs[:PeriodMemo] = options[:comment]
      attrs[:PaymentInfo] = options[:payment_info] || 'N'
      attrs[:OrderInfo] = options[:order_info] || 'N'
      attrs[:EmailModify] = options[:email_editable] || '0'
      attrs[:LangType] = options[:locale] || 'zh-tw'
      attrs[:BackURL] = options[:cancel_url]
      attrs[:ReturnURL] = Newebpay::Engine.routes.url_helpers.periodical_callbacks_url(host: Newebpay.host) if  Newebpay.config.periodical_callback
      attrs[:NotifyURL] = Newebpay::Engine.routes.url_helpers.periodical_notify_callbacks_url(host: Newebpay.host) if  Newebpay.config.periodical_notify_callback

      options[:period_type] ||= :monthly
      case options[:period_type]
      when :daily
        attrs[:PeriodType] = 'D'
      when :weekly
        attrs[:PeriodType] = 'W'
      when :monthly
        attrs[:PeriodType] = 'M'
      when :yearly
        attrs[:PeriodType] = 'Y'
      else
        raise ArgumentError, "Invalid period_type: #{options[:period_type]}"
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
