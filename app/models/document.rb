
class Document < ActiveRecord::Base
  belongs_to :listener
=begin rdoc
  The +data_file+ field contains the name of the file containing the body of the message, in marshalled form.  This method transfers that data to the +data+ field of the record.
=end
  def data_file=(name)
    f = File.open(name)
    self.data = Marshal.load(f)
    f.close
    File.delete(name)
  end
end
