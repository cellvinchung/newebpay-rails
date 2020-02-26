# frozen_string_literal: true

module Newebpay
  module PeriodicalHelper
    def render_newebpay_periodical_form(periodical_form_object, options = {})
      unless periodical_form_object.is_a? Newebpay::Periodical::Form
        raise ArgumentError, 'The first argument must be a Newebpay::Periodical::Form.'
      end

      title = options[:title] || 'Go'
      submit_class = options[:class] || ''
      submit_id = options[:id] || ''
      data = options[:data] || {}

      form_tag(Newebpay.config.periodical_gateway_url, method: :post) do
        periodical_form_object.form_attrs.each do |key, value|
          concat hidden_field_tag key, value
        end
        concat button_tag title, class: submit_class, id: submit_id, data: data
      end
    end

    def newebpay_periodical_pay_button(title, options = {})
      form = Newebpay::Periodical::Form.new(options)

      render_newebpay_periodical_form(
        form,
        title: title,
        class: options[:class],
        id: options[:id],
        data: options[:data]
      )
    end
  end
end
