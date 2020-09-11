# frozen_string_literal: true

require_dependency 'newebpay/application_controller'

module Newebpay
  class PeriodicalCallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def newebpay_response
      @newebpay_response ||= Newebpay::Periodical::Response.new(params['Period'])
    end

    def proceed
      unless Newebpay.config.periodical_callback.is_a? Proc
        raise NotImplementedError, 'Newebpay.config.periodical_callback is not a proc.'
      end
      raise InvalidResponseError if params['Period'].blank?

      instance_exec(Newebpay::Periodical::Response.new(params['Period']), self, ::Rails.application.routes.url_helpers, &Newebpay.config.periodical_callback)
      redirect_to '/' unless performed?
    end
  end
end
