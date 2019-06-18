require 'newebpay/attr_key_helper'

module Newebpay
  module Donation
    class DonationResponse
      attr_reader :status
      attr_reader :message
      attr_reader :result
      attr_reader :raw_data
      attr_reader :raw_params
      attr_reader :result_data

      def initialize(data)
        @raw_data = data

        begin
          @result_data = JSON.parse(@raw_data.to_json)
          @respond_type = :json
        rescue
          @result_data = parse_raw_params
          @respond_type = :string
        end
        @status = @result_data['Status']
        @message = @result_data['Message']

        result = @result_data['Result']

        result = JSON.parse(result) if result.is_a? String

        @result = Result.new(result)
      end

      def success?
          status && status == 'SUCCESS'
      end
      def valid?
        @result&.valid?
      end
      def parse_raw_params
        begin
          hash_params = URI::decode_www_form(@raw_params).to_h
          return_params = {}
          hash_params.each do |key, value|
            find_index = key.index('[')
            if find_index.nil?
              return_params[key] = value
            else
              parent_key = key[0...find_index]
              child_key = key[(find_index + 1)...-1]
              return_params[parent_key] ||= {}
              return_params[parent_key][child_key] = value
            end
          end
          return_params
        rescue
          nil
        end
      end
      class Result
        include AttrKeyHelper

        def initialize(data)
          @data = data
        end

        def valid?
            try(:check_code) == expected_check_code
        end

        def expected_check_value
          data = "Amt=#{@data['Amt']}&MerchantID=#{@data['MerchantID']}&MerchantOrderNo=#{@data['MerchantOrderNo']}&TimeStamp=#{@data['TimeStamp']}&Version=#{@data['Version']}"
          Newebpay::NewebpayHelper.sha256_encode_trade_info(data)
        end

        def expected_check_code
          data = "Amt=#{@data['Amt']}&MerchantID=#{@data['MerchantID']}&MerchantOrderNo=#{@data['MerchantOrderNo']}&TradeNo=#{@data['TradeNo']}"
          Newebpay::NewebpayHelper.sha256_encode(Newebpay.config.hash_key, Newebpay.config.hash_iv, data, hash_iv_first: true)
        end

        private

        def method_missing(method_name, *args)
          data_key = data_key_for(method_name)
          if data_key
            @data[data_key]
          else
            super
          end
        end

        def respond_to_missing?(method_name, _include_private = false)
          !data_key_for(method_name).nil?
        end

        def data_key_for(name)
          possible_data_keys_for(name).find { |k| @data.key?(k) }
        end

        def possible_data_keys_for(key)
          [key.to_s, convert_to_attr_key(key)]
        end

      end

    end
  end
end