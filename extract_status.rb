#!/bin/ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'


page = Nokogiri::HTML(open('http://buildsrv01:8080/job/rock/'))

page.remove_namespaces!


table = page.at_css('#configuration-matrix')


table.xpath('//img').each do |img|
    if img["src"].include? "red.png"
        img["src"] = "red.png"
    end
    if img["src"].include? "blue.png"
        img["src"] = "blue.png"
    end
    if img["src"].include? "aborted.png"
        img["src"] = "aborted.png"
    end
    if img["src"].include? "grey.png"
        img["src"] = "grey.png"
    end
end

#table.css('#model-link inside').each do |link|
#    link.remove
#end
table.xpath('//@class').remove

puts table.to_html