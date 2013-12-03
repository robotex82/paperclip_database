module Paperclip
  module Storage
    # Store files in a database.
    #
    # Usage is identical to the file system storage version, except:
    #
    # 1. In your model specify the "database" storage option; for example:
    #   has_attached_file :avatar, :storage => :database
    #
    # The files will be stored in a new database table named with the plural attachment name
    # by default, "avatars" in this example.
    #
    # 2. You need to create this new storage table with at least these columns:
    #   - file_contents
    #   - style
    #   - the primary key for the parent model (e.g. user_id)
    #
    # Note the "binary" migration will not work for the LONGBLOG type in MySQL for the
    # file_cotents column. You may need to craft a SQL statement for your migration,
    # depending on which database server you are using. Here's an example migration for MySQL:
    #
    # create_table :avatars do |t|
    #   t.string :style
    #   t.integer :user_id
    #   t.timestamps
    # end
    # execute 'ALTER TABLE avatars ADD COLUMN file_contents LONGBLOB'
    #
    # You can optionally specify any storage table name you want and whether or not deletion is done by cascading or not as follows:
    #   has_attached_file :avatar, :storage => :database, :database_table => 'avatar_files', :cascade_deletion => true
    #
    # 3. By default, URLs will be set to this pattern:
    #   /:relative_root/:class/:attachment/:id?style=:style
    #
    # Example:
    #   /app-root-url/users/avatars/23?style=original
    #
    # The idea here is that to retrieve a file from the database storage, you will need some
    # controller's code to be executed.
    #
    # Once you pick a controller to use for downloading, you can add this line
    # to generate the download action for the default URL/action (the plural attachment name),
    # "avatars" in this example:
    #   downloads_files_for :user, :avatar
    #
    # Or you can write a download method manually if there are security, logging or other
    # requirements.
    #
    # If you prefer a different URL for downloading files you can specify that in the model; e.g.:
    #   has_attached_file :avatar, :storage => :database, :url => '/users/show_avatar/:id/:style'
    #
    # 4. Add a route for the download to the controller which will handle downloads, if necessary.
    #
    # The default URL, /:relative_root/:class/:attachment/:id?style=:style, will be matched by
    # the default route: :controller/:action/:id
    #
    module Database

      def self.extended(paperclip_internal_attachment_class)
        paperclip_internal_attachment_class.instance_eval do
          attachable_class = instance.class
          setup_relation_in_attachable_class(attachable_class)
          override_default_options

        end
      end

      def copy_to_local_file(style, dest_path)
        File.open(dest_path, 'wb+') { |df| to_file(style).tap { |sf| File.copy_stream(sf, df); sf.close; sf.unlink } }
      end

      def database_path(style)
        paperclip_file = file_for(style)
        if paperclip_file
          "paperclip_database_files(id=#{paperclip_file.id},style=#{style},attachable_name=#{name})"
        else
          "paperclip_database_files(id=new,style=#{style},attachable_name=#{name})"
        end
      end

      def exists?(style = default_style)
        if original_filename
          instance.paperclip_database_files.where(style: style, attachable_name: name).exists?
        else
          false
        end
      end

      # Returns representation of the data of the file assigned to the given
      # style, in the format most representative of the current storage.
      def to_file(style = default_style)
        if @queued_for_write[style]
          @queued_for_write[style]
        elsif exists?(style)
          tempfile = Tempfile.new instance_read(:file_name)
          tempfile.binmode
          tempfile.write file_contents(style)
          tempfile.flush
          tempfile.rewind
          tempfile
        else
          nil
        end

      end

      alias_method :to_io, :to_file

      def file_for(style)
        db_result = instance.paperclip_database_files.send(:file_for, style, name)
        raise RuntimeError, "More than one result for #{name}(#{style})" if db_result.size > 1
        db_result.first
      end

      def file_contents(style = default_style)
        file_for(style).file_contents
      end

      def flush_writes
        ActiveRecord::Base.logger.info("[paperclip] Writing files for #{name}")
        @queued_for_write.each do |style, file|
          case Rails::VERSION::STRING
            when /^3/
              paperclip_file = instance.paperclip_database_files.send(:find_or_create_by_style_and_attachable_name, style, name)
            when /^4/
              paperclip_file = instance.paperclip_database_files.send(:find_or_create_by, style: style, attachable_name: name)
            else
              raise "Rails version #{Rails::VERSION::STRING} is not supported (yet)"
          end
          paperclip_file.file_contents = file.read
          paperclip_file.save!
        end
        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        ActiveRecord::Base.logger.info("[paperclip] Deleting files for #{name}")
        @queued_for_delete.uniq! ##This is apparently necessary for paperclip v 3.x
        @queued_for_delete.each do |path|
          paperclip_database_file_id = path.match(/id=([0-9]+)/)[1]
          instance.paperclip_database_files.destroy(paperclip_database_file_id)
        end
        @queued_for_delete = []
      end


      private

      def setup_relation_in_attachable_class(klass)
        klass.has_many :paperclip_database_files, as: :attachable, dependent: :destroy,
                       class_name: PaperclipDatabase::PaperclipDatabaseFile.to_s
      end

      def override_default_options
        @options[:url] = ":relative_root/:class/:attachment/:id?style=:style" if (@options[:url] == self.class.default_options[:url])
        @options[:path] = ":database_path"
      end

      module ControllerClassMethods
        def self.included(base)
          base.extend(self)
        end

        def downloads_files_for(model_name, attachment_name, options = {})
          model_name = model_name.to_s
          attachment_name = attachment_name.to_s.singularize

          define_method("#{attachment_name.pluralize}") do

            style = params[:style] || 'original'

            object = model_name.classify.constantize.send(:find, params[:id])
            attachment = object.send(attachment_name)

            send_data attachment.file_contents(style),
                      filename: object.send("#{attachment_name}_file_name"),
                      type: object.send("#{attachment_name}_content_type")
          end
        end

      end

    end
  end
end
