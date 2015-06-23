require 'net/http'
require 'open-uri'
require 'json'
require_relative 'page'

if ENV['GITHUB_ACCESS_TOKEN'].nil?
    File.open("status/issues.html","w") do |file|
        str = "Could not find access token for github not generating this page at #{Time.now}"
        file.puts str
        STDERR.puts str
        exit 0
    end
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
            STDERR.puts pulls
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
    puts "Getting issues for #{name}"
    issues[name] = get_pulls_for_repro(name)
end

count = 0
pull_count = 0
issues.each do |k,v|
    v.each do |v|
        count = count +1
        pull_count = pull_count +1 if v['html_url'].include? "pull"
    end
end

File.open("status/issues.html","w") do |file|
    base_path = "http://rock-robotics.org"
    title = "Issues of rock #{count} (PRs: #{pull_count})"
    heading = "Issues: #{count} from this #{pull_count} are Pull-requests"
    page = Page.new({page: "issues", base_path: base_path, title: title, heading: heading, issues: issues})
    file.puts page.render('template/default.html.erb')
end
