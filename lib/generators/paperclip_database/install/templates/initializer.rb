PaperclipDatabase.configure do |config|
  config.find_scope = ->(klass_name) { klass_name.constantize }
end
