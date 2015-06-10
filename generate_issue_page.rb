require 'net/http'
require 'open-uri'
require 'json'

if ENV['GITHUB_ACCESS_TOKEN'].nil?
File.open("status/issues.html","w") do |file|
    str = "Could not find access token for github not generating this page at #{Time.now}"
    file.puts str
    STDERR.puts str
    exit 0
end

#Pass as ENV the token for this script
@token="access_token=#{ENV['GITHUB_ACCESS_TOKEN']}"

def get_repros_for_organization(names)
    if names.class != Array
        names = [names]
    end
    erg = []
    names.each do |name|
        STDOUT.puts "Getting #{name}"
        uri = URI.parse("https://api.github.com/orgs/#{name}/repos?#{@token}")
        pulls = JSON.parse(Net::HTTP.get(uri))
        if pulls.class != Array 
            STDERR.puts "Failed to get #{name}"
            STDERR.puts pulls.class
            return []
        end
        pulls.each do |k|
            erg << k['full_name']
        end
    end
    erg
end

def get_pulls_for_repro(name)
    uri = URI.parse("https://api.github.com/repos/#{name}/issues?#{@token}&state=open")
    pulls = JSON.parse(Net::HTTP.get(uri))
    pulls
end

erg = get_repros_for_organization(["rock-core","rock-gui","rock-bundles","rock-control","rock-data-processing","rock-drivers","rock-gui","rock-multiagent","rock-perception","rock-planning","rock-simulation","rock-slam","rock-tutorials","orocos-toolchain"])

issues = Hash.new

erg.each do |name|
    issues[name] = get_pulls_for_repro(name)
end

count = 0
issues.each do |k,v|
    v.each do |v|
        count = count +1
    end
end

File.open("status/issues.html","w") do |file|
    file.puts "<html><head><title>Issus of rock #{count}</title></head><body>"
    file.puts "<h1>Issues (#{count})</h1>"
    issues.each do |name,iss|
        file.puts "<h2> <a href=\"http://github.com/#{name}\">Package</a> #{name} has #{iss.size} <a href=\"http://github.com/#{name}/issues?q=is%3Aopen\">issues</a></h2>" if iss.size >0
        iss.each do |is|
            file.puts "<a href=\"#{is['http_url']}\">Issue #{is['number']}</a> #{is['title']}<br/>"
        end
    end
    file.puts "This page got updated at #{Time.now}"
    file.puts "</body></html>"
end
