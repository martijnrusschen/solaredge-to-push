include ActionView::Helpers::NumberHelper

class SolarCollector
  SITE = ENV['SOLAREDGE_SITE']

  def post_to_slack
    message = "Hi Martijn, yesterday your solar panels generated #{human_power_yesterday}" +
    "Wh. That's a #{diffenrence_between_days} difference compared to the day before."

    notifier.ping message, channel: '#general', username: "RusPower"
  end

  private

  def client
    SolarEdge::Client.new(ENV['SOLAREDGE_KEY'])
  end

  def notifier
    Slack::Notifier.new "https://hooks.slack.com/services/#{ENV['SLACK_WEBHOOK']}"
  end

  def fetch_data
    SolarEdge::Site.new(client, SITE).energy(resolution: :day, start_date: Time.now-2.days, end_date: Time.now-1.day)
  end

  def power_yesterday
    fetch_data.pluck(:value).last
  end

  def human_power_yesterday
    number_with_delimiter(number_with_precision(power_yesterday, precision: 0), precision: 4)
  end

  def power_2_days_ago
    fetch_data.pluck(:value).first
  end

  def diffenrence_between_days
    difference_in_percentage(power_2_days_ago, power_yesterday)
  end

  def difference_in_percentage(old, new)
    return '+0%' if old.zero? && new.zero?

    if new.zero?
      difference = -100
    elsif old.zero?
      return ""
    else
      growth_in_percentage = (new.to_f / old.to_f) * 100
      difference = growth_in_percentage - 100
      difference = difference.round
    end

    if difference >= 0
      "+#{difference}%"
    else
      "#{difference}%"
    end
  end
end
