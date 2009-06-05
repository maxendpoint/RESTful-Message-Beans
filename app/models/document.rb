class Document < ActiveRecord::Base
  def uploaded_document=(document_field)
    self.name         = base_part_of(document_field.original_filename)
    self.content_type = document_field.content_type.chomp
    self.data         = document_field.read
  end

  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/, '')
  end
end
