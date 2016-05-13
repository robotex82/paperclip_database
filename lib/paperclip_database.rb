require 'paperclip'
require 'paperclip_database/interpolations'
require 'paperclip_database/paperclip_database_file'
require 'paperclip_database/attachments_responder_middleware'
require 'paperclip_database/railtie'
require 'paperclip/storage/database'
require 'paperclip_database/version'
require 'paperclip_database/configuration'

module PaperclipDatabase
  extend Configuration
end
