# frozen_string_literal: true

module Newebpay::Periodical
  class Response
    attr_reader :status, :message
    def initialize(response_params)
      raw_params = Newebpay::NewebpayHelper.decrypt_data(response_params)

      response_data = JSON.parse(raw_params)
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
  end
end
