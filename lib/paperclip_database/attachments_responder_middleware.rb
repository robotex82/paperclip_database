module PaperclipDatabase
  class AttachmentsResponderMiddleware

    def initialize(app)
      @app = app
    end

    def call(env)
      return send_image(env) if paperclip_database_request?(env)

      @app.call(env)
    end


    private

    def paperclip_database_request?(env)
      env['REQUEST_URI'] =~ /paperclip_database/
    end

    def send_image(env)
      id, attachment_name, *klass_name =  env['PATH_INFO'].split('/').reverse

      klass_name = klass_name.reverse.reject!(&:blank?).join("_")
      style = Rack::Utils.parse_query(env['QUERY_STRING'], '&')['style']

      model = klass_name.classify.constantize.send(:find, id)
      paperclip_attachment = model.send(attachment_name.singularize)
      file_name = model.send("#{attachment_name.singularize}_file_name")

      [
          200,
          {'Content-Type' => paperclip_attachment.content_type, 'Content-Disposition' => "inline; filename=#{file_name}"},
          [paperclip_attachment.file_contents(style)]
      ]
    end

  end
end
