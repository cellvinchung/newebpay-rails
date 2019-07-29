module Newebpay
	module DonationHelper
		def newebpay_donation_form_for(
	          donation_form_object,
	          submit: '捐款',
	          submit_class: '',
	          submit_id: '',
	          donation_url: {},
	          merchant_id: {}
	        )
	          unless donation_form_object.is_a? Newebpay::Donation::DonationForm
	            raise ArgumentError, "The first argument must be a Newebpay::Donation::DonationForm."
	          end

	          form_tag(donation_url, method: :post) do

	            donation_form_object.sorted_attrs.each do |param_pair|
		          name, value = param_pair
		          concat hidden_field_tag name, value
		        end

	            concat submit_tag submit, class: submit_class, id: submit_id
	          end
	    end

	    def newebpay_donation_pay_button(title, donation_url, options)
	    	raise ArgumentError, 'Missing required argument: donation_url.' unless donation_url
	      raise ArgumentError, 'Missing required argument: order_number.' unless options[:order_number]
	      raise ArgumentError, 'Missing required argument: description.' unless options[:description]
	      raise ArgumentError, 'Missing required argument: price.' unless options[:price]

	      form_attributes = options.except(
	      	:donation_url,
	        :order_number,
	        :description,
	        :price,
	        :email,
	        :payment_methods,
	        :anonymous,
	        :class,
	        :name,
	        :uni_no,
	        :phone,
	        :id_address,
	        :address,
	        :receipt,
	        :receipt_name,
	        :receipt_address,
	        :template_type,
	        :return_url,
	        :id
	      )

	      @merchant_id = options[:merchant_id] || Newebpay.config.merchant_id

	      form_attributes[:MerchantID] = @merchant_id
	      form_attributes[:MerchantOrderNo] = options[:order_number]
	      form_attributes[:ItemDesc] = options[:description]
	      form_attributes[:Amt] = options[:price]
	      form_attributes[:Templates] = options[:template_type] || "donate"
	      form_attributes[:ExpireDate] = options[:expire_date]
	      form_attributes[:Nickname] = options[:anonymous] || "off"
	      form_attributes[:PaymentMAIL] = options[:email]
	      form_attributes[:PaymentName] = options[:name]
	      form_attributes[:PaymentID] = options[:uni_no]
	      form_attributes[:PaymentTEL] = options[:phone]
	      form_attributes[:PaymentRegisterAddress] = options[:id_address]
	      form_attributes[:PaymentMailAddress] = options[:address]
	      form_attributes[:Receipt] = options[:receipt] || "on"
	      form_attributes[:ReceiptTitle] = options[:receipt_name]
	      form_attributes[:PaymentReceiptAddress] = options[:receipt_address]
	      form_attributes[:ReturnURL] = options[:return_url]
	      form = Newebpay::Donation::DonationForm.new(form_attributes)

	      if [80, 443].include?(request.port) && Newebpay.config.donation_notify_callback
	        form.notify_url =
	          Newebpay::Engine.routes.url_helpers.donation_notify_callbacks_url(host: request.base_url)
	      end

	      ["CREDIT", "WEBATM", "VACC", "CVS", "BARCODE"].each do |default_payment|
	      	form.set_attr default_payment, 'off'
	      end
	      if options[:payment_methods].is_a? Array
	        options[:payment_methods].each do |payment_method|
	          if payment_method.is_a?(Symbol)
	            case payment_method
	            when :credit
	              form.set_attr 'CREDIT', 'on'
	            when :credit_card
	              form.set_attr 'CREDIT', 'on'
	            when :webatm
	              form.set_attr 'WEBATM', 'on'
	            when :vacc
	              form.set_attr 'VACC', 'on'
	            when :cvs
	              form.set_attr 'CVS', 'on'
	            when :barcode
	              form.set_attr 'BARCODE', 'on'
	            else
	              form.set_attr payment_method, 'on'
	            end
	          end
	        end
	      end

	      newebpay_donation_form_for(
	        form,
	        submit: title,
	        submit_class: options[:class],
	        submit_id: options[:id],
	        donation_url: donation_url,
	        merchant_id: @merchant_id
	      )
	    end
	end
end