require 'solar_collector'

desc "This task is called by the Heroku scheduler add-on"
task :daily_post => :environment do
  SolarCollector.new.post_to_slack
end

task :daily_push_notification => :environment do
  SolarCollector.new.send_push_notification
end
