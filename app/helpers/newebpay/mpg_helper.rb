module Newebpay
  module MPGHelper
    def newebpay_mpg_form_for(
          mpg_form_object,
          submit: 'Go',
          submit_class: '',
          submit_id: '',
          mpg_gateway_url: {},
          merchant_id: {}
        )
          unless mpg_form_object.is_a? Newebpay::MPG::MPGForm
            raise ArgumentError, "The first argument must be a Newebpay::MPG::MPGForm."
          end

          form_tag(mpg_gateway_url, method: :post) do

            concat hidden_field_tag :MerchantID, merchant_id
            concat hidden_field_tag :TradeInfo, mpg_form_object.trade_info
            concat hidden_field_tag :TradeSha, mpg_form_object.trade_sha
            concat hidden_field_tag :Version, mpg_form_object.version

            concat submit_tag submit, class: submit_class, id: submit_id
          end
    end

    def newebpay_mpg_pay_button(title, options)
      raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]
      raise ArgumentError, 'Missing required argument: description.' unless options[:description]
      raise ArgumentError, 'Missing required argument: price.' unless options[:price]
      raise ArgumentError, 'Missing required argument: email.' unless options[:email]

      form_attributes = options.except(
        :order_number,
        :description,
        :price,
        :email,
        :payment_methods,
        :cvscom,
        :mpg_gateway_url,
        :cancel_url,
        :class,
        :id
      )

      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id

      form_attributes[:MerchantOrderNo] = options[:order_number]
      form_attributes[:ItemDesc] = options[:description]
      form_attributes[:Amt] = options[:price]
      form_attributes[:Email] = options[:email]
      form_attributes[:CVSCOM] = options[:cvscom]
      form_attributes[:LoginType] = options[:login_required] || "0"
      form_attributes[:MerchantID] = @merchant_id
      form_attributes[:LangType] = options[:locale] || "zh-tw"
      form_attributes[:TradeLimit] = options[:trade_limit]
      form_attributes[:ExpireDate] = options[:expire_date]
      form_attributes[:ClientBackURL] = options[:cancel_url]
      form_attributes[:OrderComment] = options[:comment]
      form_attributes[:EmailModify] = options[:email_editable] || "0"
      
      form = Newebpay::MPG::MPGForm.new(form_attributes)

      form.return_url = Newebpay::Engine.routes.url_helpers.mpg_callbacks_url(host: request.host, port: request.port)

      if [80, 443].include?(request.port) && Newebpay.config.payment_code_callback
        form.customer_url =
          Newebpay::Engine.routes.url_helpers.payment_code_callbacks_url(host: request.host, port: request.port)
      end

      if [80, 443].include?(request.port) && Newebpay.config.notify_callback
        form.notify_url =
          Newebpay::Engine.routes.url_helpers.notify_callbacks_url(host: request.host, port: request.port)
      end

      if options[:payment_methods].is_a? Array
        options[:payment_methods].each do |payment_method|
          if payment_method.is_a?(Symbol)
            case payment_method
            when :credit
              form.set_attr 'CREDIT', '1'
            when :credit_card
              form.set_attr 'CREDIT', '1'
            when :credit_red
              form.set_attr 'CreditRed', '1'
            when :unionpay
              form.set_attr 'UNIONPAY', '1'
            when :webatm
              form.set_attr 'WEBATM', '1'
            when :vacc
              form.set_attr 'VACC', '1'
            when :cvs
              form.set_attr 'CVS', '1'
            when :barcode
              form.set_attr 'BARCODE', '1'
            when :android_pay
              form.set_attr 'ANDROIDPAY', '1'
            when :samsung_pay
              form.set_attr 'SAMSUNGPAY', '1'
            when :p2g
              form.set_attr 'P2G', '1'
            else
              form.set_attr payment_method, '1'
            end
          end
          if payment_method.is_a?(Hash)
            case payment_method.keys[0]
            when :inst_flag
              form.set_attr 'InstFlag', payment_method.values[0]
            end
          end
        end
      end

      newebpay_mpg_form_for(
        form,
        submit: title,
        submit_class: options[:class],
        submit_id: options[:id],
        mpg_gateway_url: options[:mpg_gateway_url] || Newebpay.config.mpg_gateway_url,
        merchant_id: @merchant_id
      )
    end
  end
end