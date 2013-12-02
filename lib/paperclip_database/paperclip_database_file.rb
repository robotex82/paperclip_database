module PaperclipDatabase
  class PaperclipDatabaseFile < ActiveRecord::Base

    validates_uniqueness_of :style, scope: [:attachable_id, :attachable_type, :attachable_name]

    scope :file_for, ->(style) { where('style = ?', style) }

  end
end
