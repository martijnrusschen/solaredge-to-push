include ActionView::Helpers::NumberHelper

class SolarCollector
  SITE = ENV['SOLAREDGE_SITE']

  def post(resolution)
    data = fetch_data(resolution)
    post_to_slack(@human_new_value, @old_value, @new_value)
  end

  def post_to_slack(human_new_value, old_value, new_value)
    message = "Hi Martijn, yesterday your solar panels generated #{human_new_value}" +
    "Wh. That's a #{difference_in_percentage(old_value, new_value)} difference compared to the day before."

    notifier.ping message, channel: '#random', username: "RusPower"
  end

  private

  def fetch_data(resolution)
    raw_data = SolarEdge::Site.new(client, SITE).energy(resolution: resolution, start_date: Time.now-2.days, end_date: Time.now-1.day)

    @old_value = raw_data.pluck(:value).first
    @new_value = raw_data.pluck(:value).last
    @human_new_value = human_new_value(@new_value)
  end

  def client
    SolarEdge::Client.new(ENV['SOLAREDGE_KEY'])
  end

  def notifier
    Slack::Notifier.new "https://hooks.slack.com/services/#{ENV['SLACK_WEBHOOK']}"
  end

  def human_new_value(new_value)
    number_with_delimiter(number_with_precision(new_value, precision: 0), precision: 4)
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
