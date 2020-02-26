# frozen_string_literal: true

module Newebpay::CloseFund
  # 請款
  class Request < Base
    def close_type
      @close_type ||= '1'
    end
  end
end
