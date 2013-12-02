Paperclip.interpolates(:database_path) do |attachment, style|
  attachment.database_path(style)
end

Paperclip.interpolates(:relative_root) do |attachment, style|
  begin
    if ActionController::AbstractRequest.respond_to?(:relative_url_root)
      relative_url_root = ActionController::AbstractRequest.relative_url_root
    end
  rescue NameError
  end

  if !relative_url_root && ActionController::Base.respond_to?(:relative_url_root)
    ActionController::Base.relative_url_root
  end
end