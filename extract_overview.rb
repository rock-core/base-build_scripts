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

    if img["src"].include? "/static/e427e263/images/16x16/"
        tmp = img["src"]
        tmp.slice! "/static/e427e263/images/16x16/"
	img["src"] = tmp
    end
    if img["src"].include? "/static/e427e263/images/32x32/health"
        #tmp = img["src"]
        #tmp.slice! "/static/e427e263/images/32x32/"
	#img["src"] = tmp
	img.remove
	next
    end
    if img["src"].include? "/static/e427e263/images/32x32/"
        tmp = img["src"]
        tmp.slice! "/static/e427e263/images/32x32/"
	img["src"] = tmp
    end
    if img["src"]=="/static/e427e263/images/24x24/clock.png"
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



table.xpath('//@class').remove

puts table.to_html

