#!/bin/ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'

base_url="http://buildsrv01:8080"

page = Nokogiri::HTML(open("#{base_url}/job/#{ARGV[0]}/lastBuild"))

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
    if img["src"].include? "red_anime.gif"
        img["src"] = "red_anime.gif"
    end
    if img["src"].include? "blue_anime.gif"
        img["src"] = "blue_anime.gif"
    end
    if img["src"].include? "aborted_anime.gif"
        img["src"] = "aborted_anime.gif"
    end
    if img["src"].include? "grey_anime.gif"
        img["src"] = "grey_anime.gif"
    end
end

#table.css('#model-link inside').each do |link|
#    link.remove
#end
table.xpath('//@class').remove

#copy log files
table.css('a').each do |a|
    if a["href"]
        consoleurl = base_url + a["href"] + "consoleText"
        consolefileurl = a["href"] + "console"
        console = open(consoleurl)
	FileUtils.mkdir_p File.dirname("status"+consolefileurl)
	consolecopy = File.open("status"+consolefileurl,'w')
	console.each_line do |line|
	    consolecopy.write(line)
	end
	consolecopy.close
	console.close
	a["href"] = consolefileurl[1..-1]
    end
end

puts table.to_html

