#
# Test program to create and debug WWW.Mechanize file uploads
#
require 'rubygems'
require 'mechanize'

agent = WWW::Mechanize.new 
agent.user_agent_alias = 'Linux Mozilla'
page = agent.get('http://localhost:3000/pictures/new')
puts "page --> #{page.inspect}"
