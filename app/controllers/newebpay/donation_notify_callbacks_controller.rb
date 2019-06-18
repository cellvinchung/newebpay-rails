require_dependency 'newebpay/application_controller'

module Newebpay
  class DonationNotifyCallbacksController < ApplicationController
    def proceed
      raise NotImplementedError, 'Newebpay.config.donation_notify_callback is not a proc.' unless Newebpay.config.donation_notify_callback.is_a? Proc
      raise InvalidResponseError if params.blank?
      instance_exec(Newebpay::Donation::DonationResponse.new(params), self, ::Rails.application.routes.url_helpers, &Newebpay.config.donation_notify_callback)
      head 200
    end
  end
end