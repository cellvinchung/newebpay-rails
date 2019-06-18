module Newebpay
  class Engine < ::Rails::Engine
    isolate_namespace Newebpay

    config.to_prepare do
      ::ApplicationController.helper(Newebpay::Engine.helpers)
    end
  end
end