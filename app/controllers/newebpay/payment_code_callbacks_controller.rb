require_dependency 'newebpay/application_controller'

module Newebpay
  class PaymentCodeCallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def proceed
      raise NotImplementedError, 'Newebpay.config.payment_code_callback is not a proc.' unless Newebpay.config.payment_code_callback.is_a? Proc
      raise InvalidResponseError if params["TradeInfo"].blank?
      instance_exec(Newebpay::Response.new(params["TradeInfo"]), self, ::Rails.application.routes.url_helpers, &Newebpay.config.payment_code_callback)
      redirect_to '/' unless performed?
    end
  end
end