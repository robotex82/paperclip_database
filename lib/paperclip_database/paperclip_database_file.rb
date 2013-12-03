module PaperclipDatabase
  class PaperclipDatabaseFile < ActiveRecord::Base

    validates_uniqueness_of :style, scope: [:attachable_id, :attachable_type, :attachable_name]

    scope :file_for, ->(style, attachment_name) { where(style: style, attachable_name: attachment_name) }

  end
end
