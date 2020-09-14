# frozen_string_literal: true

module Newebpay::CancelAuth
  class Response
    SLICE_ATTRS = %w[Amt MerchantID MerchantOrderNo TradeNo].freeze
    attr_reader :status, :message, :result

    def initialize(response_params)
      response_data = Oj.load(response_params)

      @status = response_data['Status']
      @message = response_data['Message']

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

    def valid?
      check_code == expected_check_code
    end

    def expected_check_code
      Newebpay::Helpers.create_check_code(@result.slice(*SLICE_ATTRS))
    end
  end
end
