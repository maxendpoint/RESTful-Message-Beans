class Image < ActiveRecord::Base
  def uploaded_image=(image_field)
    self.name         = base_part_of(image_field.original_filename)
    self.content_type = image_field.content_type.chomp
    self.data         = image_field.read
  end

  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/, '')
  end
end
