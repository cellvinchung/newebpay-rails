require 'newebpay/attr_key_helper'

module Newebpay
  module Donation
    class DonationForm
      include AttrKeyHelper

      REQUIRED_ATTRS = %w(MerchantID RespondType TimeStamp Version MerchantOrderNo Amt ItemDesc).freeze

      def initialize(attrs)
        unless attrs.is_a? Hash
          raise ArgumentError, "When initializing #{self.class.name}, you must pass a hash as an argument."
        end

        @attrs = {}
        missing_attrs = REQUIRED_ATTRS.map(&:clone)

        attrs.each_pair do |k, v|
          key = k.to_s
          value = v.to_s
          missing_attrs.delete(key)
          @attrs[key] = value
        end
        
        if @attrs['Version'].nil?
          @attrs['Version'] = version
          missing_attrs.delete('Version')
        end

        if @attrs['TimeStamp'].nil?
          @attrs['TimeStamp'] = Time.now.to_i
          missing_attrs.delete('TimeStamp')
        end
        if @attrs['RespondType'].nil?
          @attrs['RespondType'] = "JSON"
          missing_attrs.delete('RespondType')
        end
        @attrs["CheckValue"] = check_value
        return self if missing_attrs.count.zero?
        raise ArgumentError, "The required attrs: #{missing_attrs.map { |s| "'#{s}'" }.join(', ')} #{missing_attrs.count > 1 ? 'are' : 'is'} missing."
      end

      def set_attr(name, value)
        @attrs[name] = value
      end

      def sorted_attrs
        @attrs.sort
      end

      def to_s
        sorted_attrs.map { |k, v| "#{k}=#{v}" }.join('&')
      end

      def check_value
        data = "Amt=#{@attrs['Amt']}&MerchantID=#{@attrs['MerchantID']}&MerchantOrderNo=#{@attrs['MerchantOrderNo']}&TimeStamp=#{@attrs['TimeStamp']}&Version=#{@attrs['Version']}"
        Newebpay::NewebpayHelper.sha256_encode(Newebpay.config.hash_key, Newebpay.config.hash_iv, data)
      end

      def get_url_params
        URI.encode_www_form(@attrs)
      end

      def version
        "1.0"
      end
      private

      def method_missing(method_name, *args)
        attr_key = convert_to_attr_key(method_name)

        if @attrs.key?(attr_key)
          @attrs[attr_key]
        elsif attr_key.end_with?('=') && args[0]
          @attrs[attr_key.chomp('=')] = args[0]
        else
          super
        end
      end

      def respond_to_missing?(method_name, _include_private = false)
        attr_key = convert_to_attr_key(method_name)

        attr_key.end_with?('=') || @attrs.key?(attr_key) || sup
      end
    end
  end
end