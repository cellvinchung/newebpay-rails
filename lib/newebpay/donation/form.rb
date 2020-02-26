# frozen_string_literal: true

module Newebpay::Donation
  class Form
    attr_accessor :attrs, :merchant_id, :donation_url
    REQUIRED_ATTRS = %i[order_number description price].freeze
    PAYMENT_METHODS = %i[credit webatm vacc cvs barcode].freeze

    def initialize(donation_url, options)
      @attrs = {}
      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id
      @donation_url = donation_url

      check_valid(options)
      parse_attr(options)

      @attrs['Version'] = version
      @attrs['TimeStamp'] = Time.now.to_i
      @attrs['RespondType'] = 'JSON'
      @attrs['CheckValue'] = check_value
    end

    def form_attrs
      @form_attrs ||= @attrs
    end

    def check_value
      @check_value ||= Newebpay::NewebpayHelper.sha256_encode(Newebpay.config.hash_key, Newebpay.config.hash_iv, check_value_raw)
    end

    def check_value_raw
      URI.encode_www_form(attrs.slice('Amt', 'MerchantID', 'MerchantOrderNo', 'TimeStamp', 'Version').sort)
    end

    def version
      '1.0'
    end

    private

    def parse_attr(options)
      attrs['MerchantID'] = merchant_id
      attrs['MerchantOrderNo'] = options[:order_number]
      attrs['ItemDesc'] = options[:description]
      attrs['Amt'] = options[:price]
      attrs['Templates'] = options[:template_type] || 'donate'
      attrs['ExpireDate'] = options[:expire_date]
      attrs['Nickname'] = options[:anonymous] ? 'on' : 'off'
      attrs['PaymentMAIL'] = options[:email]
      attrs['PaymentName'] = options[:name]
      attrs['PaymentID'] = options[:uni_no]
      attrs['PaymentTEL'] = options[:phone]
      attrs['PaymentRegisterAddress'] = options[:id_address]
      attrs['PaymentMailAddress'] = options[:address]
      attrs['Receipt'] = 'on'
      attrs['ReceiptTitle'] = options[:receipt_name]
      attrs['PaymentReceiptAddress'] = options[:receipt_address]
      attrs['ReturnURL'] = options[:return_url]
      attrs['NotifyURL'] = Newebpay::Engine.routes.url_helpers.donation_notify_callbacks_url(host: Newebpay.host) if Newebpay.config.donation_notify_callback

      options[:payment_methods].each do |payment_method|
        attrs[payment_method.to_s.upcase] = 'on'
      end
    end

    def check_valid(options)
      unless options.is_a? Hash
        raise ArgumentError, "When initializing #{self.class.name}, you must pass a hash."
      end

      raise ArgumentError, 'Missing required argument: donation_url.' unless donation_url

      unless Newebpay.config.donation_notify_callback
        raise ArgumentError, 'Missing donation_notify_callback block in initializer'
      end

      %i[order_number description price].each do |argument|
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
