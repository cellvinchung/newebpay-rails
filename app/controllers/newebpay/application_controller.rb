module Newebpay
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    protect_from_forgery prepend: true
    private

    def newebpay_response
      return @newebpay_response if @newebpay_response
      if params["TradeInfo"].present?
        @newebpay_response = Newebpay::Response.new(params["TradeInfo"])
      elsif params["Period"].present?
        @newebpay_response = Newebpay::Response.new(params["Period"])
      else
        return nil
      end
      # raise InvalidResponseError unless @newebpay_response.result.valid?
      @newebpay_response
    end

    class InvalidResponseError < StandardError
    end

    def respond_to_missing?(method)
      super || ::Rails.application.routes.url_helpers.respond_to?(method)
    end

    def method_missing(method, *args)
      if ::Rails.application.routes.url_helpers.respond_to?(method)
        ::Rails.application.routes.url_helpers.try(method, *args)
      else
        super
      end
    end
  end
end