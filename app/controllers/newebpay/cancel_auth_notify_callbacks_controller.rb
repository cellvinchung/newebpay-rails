require_dependency 'newebpay/application_controller'

module Newebpay
  class CancelAuthNotifyCallbacksController < ApplicationController
    def proceed
      raise NotImplementedError, 'Newebpay.config.cancel_auth_notify_callback is not a proc.' unless Newebpay.config.cancel_auth_notify_callback.is_a? Proc
      raise InvalidResponseError if params.blank?
      instance_exec(Newebpay::CancelAuth::Response.new(params), self, ::Rails.application.routes.url_helpers, &Newebpay.config.cancel_auth_notify_callback)
      head 200
    end
  end
end