#!/bin/ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'

file = open("http://buildsrv01:8080/view/Rock/")
overview = Nokogiri::HTML(file).remove_namespaces!

#remove headline
overview.at_xpath('//tr').remove


table = overview.at_css('#projectstatus')

table.xpath('//img').each do |img|

    tmp = File.basename(img["src"])
    img["src"] = tmp

#    if img["src"].include? "health"
#	img.remove
#    end
    if img["src"]=="clock.png"
	img.remove
    end
end

table.xpath('//th').each do |th|

    if th.content == "W" || th.content == '\u00A0\u00A0\u00A0S' || th.content == '&nbsp;&nbsp;&nbsp;W'
	th.content = "Status"
    end

    if th.content ==  "%"
	th.content = "% success"
    end
    if th.content ==  "Description"
	th.content = ""
    end
end
table.xpath('//td').each do |td|
    if td.content ==  '&Acirc;&nbsp;'
	td.content = "test"
    end
end



#table.xpath('//@class').remove
table.xpath('//@href').remove

puts '<link rel="stylesheet" type="text/css" href="jenkins_style.css">'
puts table.to_html.gsub("&nbsp;", "").gsub("&Acirc;","")

