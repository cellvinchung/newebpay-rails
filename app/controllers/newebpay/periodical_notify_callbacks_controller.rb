require_dependency 'newebpay/application_controller'

module Newebpay
  class PeriodicalNotifyCallbacksController < ApplicationController
    def proceed
      raise NotImplementedError, 'Newebpay.config.periodical_notify_callback is not a proc.' unless Newebpay.config.periodical_notify_callback.is_a? Proc
       raise InvalidResponseError if params["Period"].blank?
      instance_exec(Newebpay::Response.new(params["Period"]), self, ::Rails.application.routes.url_helpers, &Newebpay.config.periodical_notify_callback)
      head 200
    end
  end
end