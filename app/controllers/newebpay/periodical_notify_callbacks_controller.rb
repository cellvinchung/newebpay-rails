# frozen_string_literal: true

require_dependency 'newebpay/application_controller'

module Newebpay
  class PeriodicalNotifyCallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def newebpay_response
      @newebpay_response ||= Newebpay::MPG::Response.new(params['Period'])
    end

    def proceed
      unless Newebpay.config.periodical_notify_callback.is_a? Proc
        raise NotImplementedError, 'Newebpay.config.periodical_notify_callback is not a proc.'
      end
      raise InvalidResponseError if params['Period'].blank?

      instance_exec(Newebpay::Periodical::Response.new(params['Period']), self, ::Rails.application.routes.url_helpers, &Newebpay.config.periodical_notify_callback)
      head 200
    end
  end
end
