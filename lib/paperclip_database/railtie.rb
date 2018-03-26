module PaperclipDatabase

  class Railtie < Rails::Railtie
    initializer "paperclip_database_attachments_responder.configure_rails_initialization" do |app|
      if Rails.version < '5.0.0'
        app.middleware.use 'PaperclipDatabase::AttachmentsResponderMiddleware'
      else
        app.middleware.use PaperclipDatabase::AttachmentsResponderMiddleware
      end
    end
  end

end
