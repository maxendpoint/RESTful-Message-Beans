# == Schema Information
#
# Table name: pictures
#
#  id           :integer(4)      not null, primary key
#  comment      :string(255)
#  name         :string(255)
#  content_type :string(255)
#  data         :binary(16777215
#

require 'test_helper'

class PictureTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
