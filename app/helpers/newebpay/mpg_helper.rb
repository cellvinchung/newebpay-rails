# frozen_string_literal: true

module Newebpay
  module MPGHelper
    def render_newebpay_mpg_form(mpg_form_object, options = {})
      unless mpg_form_object.is_a? Newebpay::MPG::Form
        raise ArgumentError, 'The first argument must be a Newebpay::MPG::Form.'
      end

      title = options[:title] || 'Go'
      submit_class = options[:class] || ''
      submit_id = options[:id] || ''
      data = options[:data] || {}

      form_tag(Newebpay.config.mpg_gateway_url, method: :post) do
        mpg_form_object.form_attrs.each do |key, value|
          concat hidden_field_tag key, value
        end
        concat button_tag title, class: submit_class, id: submit_id, data: data
      end
    end

    def newebpay_mpg_pay_button(title, options = {})
      form = Newebpay::MPG::Form.new(options)

      render_newebpay_mpg_form(
        form,
        title: title,
        class: options[:class],
        id: options[:id],
        data: options[:data]
      )
    end
  end
end
