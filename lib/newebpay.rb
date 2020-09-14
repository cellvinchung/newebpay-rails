# frozen_string_literal: true

require 'active_record'
require 'http'

require 'newebpay/version'
require 'newebpay/config'
require 'newebpay/error_codes'
require 'newebpay/bank_codes'
require 'newebpay/engine'
require 'newebpay/helpers'
require 'newebpay/mpg/form'
require 'newebpay/mpg/response'
require 'newebpay/periodical/form'
require 'newebpay/periodical/response'
require 'newebpay/donation/form'
require 'newebpay/donation/response'
require 'newebpay/query_trade/search'
require 'newebpay/query_trade/response'
require 'newebpay/cancel_auth/request'
require 'newebpay/cancel_auth/response'
require 'newebpay/close_fund/base'
require 'newebpay/close_fund/refund'
require 'newebpay/close_fund/request'
require 'newebpay/close_fund/response'
module Newebpay
  HASH_KEY = Newebpay.config.hash_key
  HASH_IV = Newebpay.config.hash_iv

  def self.host
    @host ||= ::Rails.application.routes.default_url_options[:host]
  end

  def self.configure
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  def self.create_trade_info(attrs, key = HASH_KEY, iv = HASH_IV)
    Helpers.create_trade_info(attrs, key, iv)
  end
  alias create_post_data create_trade_info

  def self.create_trade_sha(trade_info, key = HASH_KEY, iv = HASH_IV)
    Helpers.create_trade_sha(trade_info, key, iv)
  end

  # mpg, periodical
  def self.decrypt_trade_info(trade_info, key = HASH_KEY, iv = HASH_IV)
    Helpers.decrypt_trade_info(trade_info, key, iv)
  end
  alias decrypt_period decrypt_trade_info

  # donation, cancel_auth
  def self.create_check_value(attrs, key = HASH_KEY, iv = HASH_IV)
    Helpers.create_check_value(attrs, key, iv)
  end
  alias expect_check_code create_check_value

  # query_trade
  def self.query_check_value(attrs, key = HASH_KEY, iv = HASH_IV)
    Helpers.query_check_value(attrs, key, iv)
  end

  # query_trade
  def self.query_check_code(attrs, key = HASH_KEY, iv = HASH_IV)
    Helpers.query_check_code(attrs, key, iv)
  end

  def self.error_message(code)
    ErrorCodes.error_codes[code.to_sym]
  end
  alias get_error_message error_message

  def self.bank(bank_code)
    BankCodes.bank_codes(bank_code.to_sym)
  end
end
