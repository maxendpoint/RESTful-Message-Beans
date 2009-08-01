# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def generate_heads(array)
    reply = "<thead>\n<tr>\n"
    array.each do |s|
      reply += "<th>#{s}</th>\n"
    end
    reply += "</tr>\n</thead>\n"
    reply
  end
end
