# frozen_string_literal: true

module Newebpay::MPG
  class Response
    attr_reader :status, :message, :trade_info, :trade_sha
    def initialize(response_params)
      raw_params = Newebpay::NewebpayHelper.decrypt_data(response_params)

      response_data = JSON.parse(raw_params)
      @status = response_data['Status']
      @message = response_data['Message']
      @trade_info = response_data['TradeInfo']
      @trade_sha = response_data['TradeSha']
      @result = response_data['Result']

      @result.each do |key, values|
        define_singleton_method(key.underscore) do
          values
        end
      end
    end

    def success?
      status == 'SUCCESS'
    end
  end
end
