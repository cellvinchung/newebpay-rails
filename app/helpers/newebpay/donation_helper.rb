# frozen_string_literal: true

module Newebpay
  module DonationHelper
    def render_newebpay_donation_form(donation_form_object, options = {})
      unless donation_form_object.is_a? Newebpay::Donation::Form
        raise ArgumentError, 'The first argument must be a Newebpay::Donation::Form.'
      end

      title = options[:title] || 'Go'
      submit_class = options[:class] || ''
      submit_id = options[:id] || ''
      data = options[:data] || {}

      form_tag(donation_form_object.donation_url, method: :post) do
        donation_form_object.form_attrs.each do |key, value|
          concat hidden_field_tag key, value
        end

        concat button_tag title, class: submit_class, id: submit_id, data: data
      end
    end

    def newebpay_donation_pay_button(title, donation_url, options)
      form = Newebpay::Donation::Form.new(donation_url, options)

      render_newebpay_donation_form(
        form,
        title: title,
        class: options[:class],
        id: options[:id],
        data: options[:data]
      )
    end
  end
end
