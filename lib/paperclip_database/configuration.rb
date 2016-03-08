require 'active_support/core_ext/module/attribute_accessors'

module PaperclipDatabase
  module Configuration
    def configure
      yield self
    end

    mattr_accessor :before_send_image do
      lambda do |env, request|
      end
    end
  end
end
