#!/bin/ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'net/http'

base_url="http://buildsrv01:8080"

page = Nokogiri::HTML(open("#{base_url}/job/#{ARGV[0]}/lastBuild"))
page.remove_namespaces!
table = page.at_css('#configuration-matrix')

#copy log files
table.css('a').each do |a|
    if a['href']
#        binding.pry

        #Download zip of testsuites
        jobname = (a['href'].match /job\/([A-z\-_]*)/)[1]
        node = (a['href'].match /node=([A-z\-_\.0-9]*)/)[1]

        project_url = (a['href'].match /job\/(.*)\/[0-9]/)[1]

        #make jobname and nodename path-safe
        jobname = jobname.gsub("/","_").gsub(".","_")
        node = node.gsub("/","_").gsub(".","_")

        uri = URI(base_url + "/job/" + project_url + "/ws/testsuites/*zip*/testsuites.zip")
        res = Net::HTTP.get_response(uri)
        if res.code == '200'
            dir = "status/tests/#{jobname}-#{node}"
            FileUtils.rm_rf dir
	    FileUtils.mkdir_p dir
            Dir.chdir(dir) do
                File.open("archive.zip",'w') do |file|
                    file.write res.body
                end
                `unzip archive.zip`
                FileUtils.rm("archive.zip")
            end
            STDOUT.puts "Could got #{uri}"
        else
            STDERR.puts "Cannot get #{uri}"
        end
    end
end
