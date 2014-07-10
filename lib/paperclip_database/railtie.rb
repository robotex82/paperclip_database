module PaperclipDatabase

  class Railtie < Rails::Railtie
    initializer "paperclip_database_attachments_responder.configure_rails_initialization" do |app|
      app.middleware.use 'PaperclipDatabase::AttachmentsResponderMiddleware'
    end
  end

end
