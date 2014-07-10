module PaperclipDatabase
  class PaperclipDatabaseFile < ActiveRecord::Base
    belongs_to :attachable, polymorphic: true

    validates_uniqueness_of :style, scope: [:attachable_id, :attachable_type, :attachable_name]

    scope :file_for, ->(style, attachment_name) { where(style: style, attachable_name: attachment_name) }

  end
end
