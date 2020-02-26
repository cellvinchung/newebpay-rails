# frozen_string_literal: true

module Newebpay::CloseFund
  # 退款
  class Refund < Base
    def close_type
      @close_type ||= '2'
    end
  end
end
