require "active_record"
require "http"

require 'newebpay/version'
require 'newebpay/config'
require 'newebpay/error_codes'
require 'newebpay/bank_codes'
require 'newebpay/engine'
require 'newebpay/newebpay_helper'
require 'newebpay/response'
require 'newebpay/mpg/mpg_form'
require 'newebpay/periodical/periodical_form'
require 'newebpay/donation/donation_form'
require 'newebpay/donation/donation_response'
require 'newebpay/query_trade'
require 'newebpay/cancel_auth'
require 'newebpay/close_fund'
require 'newebpay/controller_helper'
module Newebpay
  def self.configure
    yield config
  end

  def self.config
    @config ||= Config.new
  end
  def self.get_error_message code
		# @@error_codes ||= ErrorCodes.new
		ErrorCodes.error_codes[code.to_sym]
  end
  def self.bank(bank_code)
  	BankCodes.bank_codes(bank_code.to_sym)
  end
end