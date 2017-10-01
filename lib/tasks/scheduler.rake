require 'solar_collector'

desc "This task is called by the Heroku scheduler add-on"
task :notify_slack => :environment do
  SolarCollector.new.post(:day)
end

task :weekly_post => :environment do
  SolarCollector.new.post(:week)
end
