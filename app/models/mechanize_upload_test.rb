#
# Test program to create and debug WWW.Mechanize file uploads
#
require 'rubygems'
require 'mechanize'

agent = WWW::Mechanize.new 
agent.user_agent_alias = 'Linux Mozilla'
page = agent.get('http://localhost:3000/pictures/new')
#puts "page --> #{page.inspect}"
form = page.forms.first
fu = form.file_uploads[0]
File.open('/home/kenb/Desktop/IMG_0862.JPG', 'r') do |f|
  fu.file_data = f.read
  fu.mime_type = 'image/jpg'
end
puts "modified form --> #{form.inspect}"
#page = agent.submit(form)
#puts "form --> #{form.inspect}"
#puts "form.name -->

