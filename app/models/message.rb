class Message < ActiveRecord::Base
  def uploaded_message=(message_field)
    self.name         = base_part_of(message_field.original_filename)
    self.content_type = message_field.content_type.chomp
    self.data         = message_field.read
  end

  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/, '')
  end
end
