# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'digest'
require 'oj'
module Newebpay
  module Helpers
    HASH_KEY = Newebpay.config.hash_key
    HASH_IV = Newebpay.config.hash_iv
    # mpg, periodical, cancel_auth, close_fund
    def self.create_trade_info(attrs, key = HASH_KEY, iv = HASH_IV)
      encode_attrs = URI.encode_www_form(attrs)
      encrypt(key, iv, encode_attrs)
    end
    alias create_post_data create_trade_info

    # mpg
    def self.create_trade_sha(trade_info, key = HASH_KEY, iv = HASH_IV)
      encode_string = "HashKey=#{key}&#{trade_info}&HashIV=#{iv}"
      Digest::SHA256.hexdigest(encode_string).upcase
    end

    # mpg, periodical
    def self.decrypt_trade_info(trade_info, key = HASH_KEY, iv = HASH_IV)
      Oj.load(decrypt(key, iv, trade_info))
    end
    alias decrypt_period decrypt_trade_info

    # donation, cancel_auth
    def self.create_check_value(attrs, key = HASH_KEY, iv = HASH_IV)
      encode_attrs = URI.encode_www_form(attrs.sort)
      encode_string = "HashKey=#{key}&#{encode_attrs}&HashIV=#{iv}"
      Digest::SHA256.hexdigest(encode_string).upcase
    end
    alias expect_check_code create_check_value

    # query_trade
    def self.query_check_value(attrs, key = HASH_KEY, iv = HASH_IV)
      encode_attrs = URI.encode_www_form(attrs.sort)
      encode_string = "IV=#{iv}&#{encode_attrs}&Key=#{key}"
      Digest::SHA256.hexdigest(encode_string).upcase
    end

    # query_trade
    def self.query_check_code(attrs, key = HASH_KEY, iv = HASH_IV)
      encode_attrs = URI.encode_www_form(attrs.sort)
      encode_string = "HashIV=#{iv}&#{encode_attrs}&HashKey=#{key}"
      Digest::SHA256.hexdigest(encode_string).upcase
    end

    def self.encrypt(key, iv, data)
      cipher = OpenSSL::Cipher::AES256.new(:CBC)
      cipher.encrypt
      cipher.padding = 0
      cipher.key = key
      cipher.iv = iv
      padding_data = add_padding(data)
      encrypted = cipher.update(padding_data) + cipher.final
      encrypted.unpack('H*').first
    end

    def self.add_padding(data, block_size = 32)
      pad = block_size - (data.length % block_size)
      data + (pad.chr * pad)
    end

    def self.decrypt(key, iv, encrypted_data)
      encrypted_data = [encrypted_data].pack('H*')
      decipher = OpenSSL::Cipher::AES256.new(:CBC)
      decipher.decrypt
      decipher.padding = 0
      decipher.key = key
      decipher.iv = iv
      data = decipher.update(encrypted_data) + decipher.final
      strippadding data
    end

    def self.strippadding(data)
      slast = data[-1].ord
      slastc = slast.chr
      padding_index = /#{slastc}{#{slast}}/ =~ data
      if !padding_index.nil?
        data[0, padding_index]
      else
        false
      end
    end
  end
end
