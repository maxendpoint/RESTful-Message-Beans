# == Schema Information
# Schema version: 20090612010321
#
# Table name: documents
#
#  id             :integer(4)      not null, primary key
#  listener_id    :integer(4)
#  key            :string(255)
#  destination    :string(255)
#  message_ID     :string(255)
#  content_type   :string(255)
#  priority       :string(255)
#  content_length :string(255)
#  time_stamp     :string(255)
#  expiry         :string(255)
#  data           :binary(16777215
#  created_at     :datetime
#  updated_at     :datetime
#

class Document < ActiveRecord::Base
  belongs_to :listener
  
  # the data_file field contains the name of the file containing the body of the
  # message, in marshalled form.  This method transfers that data to the data field
  # of the record.
  def data_file=(name)
    f = File.open(name)
    self.data = Marshal.load(f)
    f.close
    File.delete(name)
  end
end
