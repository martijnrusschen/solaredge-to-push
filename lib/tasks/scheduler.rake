require 'solar_collector'

desc "This task is called by the Heroku scheduler add-on"
task :daily_post => :environment do
  SolarCollector.new.execute(:day)
end

task :weekly_post => :environment do
  SolarCollector.new.execute(:week)
end
