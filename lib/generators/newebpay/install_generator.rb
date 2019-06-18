require 'rails/generators/base'

module Newebpay
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates the Newebpay initializer and mounts Newebpay::Rails::Engine.'

      def copy_initializer_file
        template 'newebpay_initializer.rb', ::Rails.root.join('config', 'initializers', 'newebpay.rb')
      end

      def mount_engine
        route "mount Newebpay::Engine => '/newebpay'"
      end
    end
  end
end