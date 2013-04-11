#!/usr/bin/env ruby
require 'rubygems'

$:.unshift(Dir[File.dirname(__FILE__) + "/lib/*/lib"])

require 'date'
#require 'sprint'
require 'soap/soap'
require 'jira4r'
require 'yaml'

#require 'ruby-debug'; Debugger.start
#debugger

@email, @password = 'peter@vailsys.com', 'peter8245'


sprint_file = File.dirname(__FILE__) + '/sprint.yml'

sprint_hash = YAML::load_file(sprint_file) if File.exists?(sprint_file)

sprint = sprint_hash['sprint'] if sprint_hash

begin
print "Sprint to report? (#{sprint}): "
entry = gets.chomp
sprint = entry.empty? ? sprint : entry
end until sprint =~ /\d+/
File.open(sprint_file, 'w') { |f| f.write YAML::dump('sprint' => sprint) }

puts "\nReporting for Sprint #{sprint}\n"

jira = Jira::JiraTool.new(2, 'http://jira.actconferencing.com')
jira.login(@email, @password)

logs = []

issues = jira.getIssuesFromJqlSearch("fixVersion = 'Vail Dev #{sprint}'", 10000)
issues.each do |i|
worklogs = jira.getWorklogs(i.key)
worklogs.reject! { |wl| @email != wl.author }
worklogs.each do |wl|
logs << {:key => i.key, :summary => i.summary, :date => wl.startDate, :time => wl.timeSpentInSeconds / 3600.0 }
end
end

logs.sort { |a, b| a[:date] <=> b[:date] }.each do |l|
fdate = l[:date].strftime('%b %d')
puts "#{fdate} - #{l[:key]} #{l[:summary]} - #{l[:time]}"
end

# sprint = Sprint.by_number 19
# puts sprint.week(1).map {|d| d.strftime('%b %d')}.join ' | '
