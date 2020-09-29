# frozen_string_literal: true

module Newebpay::Periodical
  class Response
    attr_reader :status, :message, :result
    def initialize(response_params)
      raw_params = Newebpay::NewebpayHelper.decrypt_data(response_params)

      response_data = JSON.parse(raw_params)
      @status = response_data['Status']
      @message = response_data['Message']
      @result = response_data['Result']&.deep_transform_keys{ |key| key.to_s.underscore }

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
