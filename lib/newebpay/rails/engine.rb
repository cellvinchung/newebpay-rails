require 'newebpay/engine'

module Newebpay
  module Rails
    class Engine < Newebpay::Engine
      isolate_namespace NewebpayRails
    end
  end
end