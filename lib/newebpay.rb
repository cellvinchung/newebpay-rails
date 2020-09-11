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
  def self.host
    @host ||= ::Rails.application.routes.default_url_options[:host]
  end

  def self.configure
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  def self.get_error_message(code)
    ErrorCodes.error_codes[code.to_sym]
  end

  def self.bank(bank_code)
    BankCodes.bank_codes(bank_code.to_sym)
  end
end
