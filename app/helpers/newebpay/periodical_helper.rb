module Newebpay
  module PeriodicalHelper
    def newebpay_periodical_form_for(
      periodical_form_object,
      submit: 'Go',
      submit_class: '',
      submit_id: '',
      periodical_gateway_url: {},
      merchant_id: {}
      )
      unless periodical_form_object.is_a? Newebpay::Periodical::PeriodicalForm
        raise ArgumentError, "The first argument must be a Newebpay::Periodical::PeriodicalForm."
      end
      
      form_tag(periodical_gateway_url, method: :post) do

        concat hidden_field_tag :"MerchantID_", merchant_id
        concat hidden_field_tag :"PostData_", periodical_form_object.trade_info

        concat submit_tag submit, class: submit_class, id: submit_id
      end
    end

    def newebpay_periodical_pay_button(title, options)
      raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]
      raise ArgumentError, 'Missing required argument: description.' unless options[:description]
      raise ArgumentError, 'Missing required argument: price.' unless options[:price]
      raise ArgumentError, 'Missing required argument: email.' unless options[:email]

      form_attributes = options.except(
        :order_number,
        :description,
        :price,
        :email,
        :period_type,
        :periodical_gateway_url,
        :class,
        :id
      )
      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id

      form_attributes[:MerOrderNo] = options[:order_number]
      form_attributes[:ProdDesc] = options[:description]
      form_attributes[:PeriodAmt] = options[:price]
      form_attributes[:PayerEmail] = options[:email]
      form_attributes[:PeriodPoint] = options[:period_point] || "01"
      form_attributes[:PeriodTimes] = options[:period_times] || "99"
      form_attributes[:PeriodStartType] = options[:check_type] || "1"
      form_attributes[:MerchantID] = @merchant_id
      form_attributes[:PeriodMemo] = options[:comment]
      form_attributes[:PaymentInfo] = options[:payment_info] || "N" 
      form_attributes[:OrderInfo] = options[:order_info] || "N" 
      form_attributes[:EmailModify] = options[:email_editable] || "0"
      form_attributes[:BackURL] = options[:cancel_url]

      @period_type = options[:period_type] || :monthly
      case @period_type.to_sym
      when :daily
        form_attributes[:PeriodType] = 'D'
      when :weekly
        form_attributes[:PeriodType] = 'W'
      when :monthly
        form_attributes[:PeriodType] = 'M'
      when :yearly
        form_attributes[:PeriodType] = 'Y'
      end

      form = Newebpay::Periodical::PeriodicalForm.new(form_attributes)
      
      form.return_url =
        Newebpay::Engine.routes.url_helpers.periodical_callbacks_url(host: request.base_url)


      if [80, 443].include?(request.port) && Newebpay.config.periodical_notify_callback
        form.notify_url =
          Newebpay::Engine.routes.url_helpers.periodical_notify_callbacks_url(host: request.base_url)
      end

      newebpay_periodical_form_for(
        form,
        submit: title,
        submit_class: options[:class],
        submit_id: options[:id],
        periodical_gateway_url: options[:periodical_gateway_url] || Newebpay.config.periodical_gateway_url,
        merchant_id: @merchant_id
      )
    end
  end
end