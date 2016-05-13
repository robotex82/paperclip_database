module PaperclipDatabase
  module Configuration
    def configure
      yield self
    end

    mattr_accessor :find_scope do
      ->(klass_name) { klass_name.constantize }
    end
  end
end