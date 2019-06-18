module Newebpay

  class Config
    include ActiveSupport::Configurable
    config_accessor :merchant_id
    config_accessor :hash_iv, :hash_key
    config_accessor :mpg_gateway_url, :periodical_gateway_url, :query_trade_url, :cancel_auth_url, :close_fund_url
    config_accessor :mpg_callback, :notify_callback, :payment_code_callback, :periodical_callback, :periodical_notify_callback, :donation_notify_callback, :cancel_auth_notify_callback

    def mpg_callback(&block)
      if block
        config.mpg_callback = block
      else
        config.mpg_callback
      end
    end

    def notify_callback(&block)
      if block
        config.notify_callback = block
      else
        config.notify_callback
      end
    end

    def payment_code_callback(&block)
      if block
        config.payment_code_callback = block
      else
        config.payment_code_callback
      end
    end
    def periodical_callback(&block)
      if block
        config.periodical_callback = block
      else
        config.periodical_callback
      end
    end
    def periodical_notify_callback(&block)
      if block
        config.periodical_notify_callback = block
      else
        config.periodical_notify_callback
      end
    end

    def donation_notify_callback(&block)
      if block
        config.donation_notify_callback = block
      else
        config.donation_notify_callback
      end
    end

    def cancel_auth_notify_callback(&block)
      if block
        config.cancel_auth_notify_callback = block
      else
        config.cancel_auth_notify_callback
      end
    end
  end

end