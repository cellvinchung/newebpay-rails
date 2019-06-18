require_dependency 'newebpay/application_controller'

module Newebpay
  class NotifyCallbacksController < ApplicationController
    def proceed
      raise NotImplementedError, 'Newebpay.config.notify_callback is not a proc.' unless Newebpay.config.notify_callback.is_a? Proc
      raise InvalidResponseError if params["TradeInfo"].blank?
      instance_exec(Newebpay::Response.new(params["TradeInfo"]), self, ::Rails.application.routes.url_helpers, &Newebpay.config.notify_callback)
      head 200
    end
  end
end