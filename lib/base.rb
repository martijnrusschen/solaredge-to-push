include ActionView::Helpers::NumberHelper

module Base
  SITE = ENV['SOLAREDGE_SITE']

  def client
    SolarEdge::Client.new(ENV['SOLAREDGE_KEY'])
  end

  def notifier
    Slack::Notifier.new "https://hooks.slack.com/services/#{ENV['SLACK_WEBHOOK']}"
  end

  def new_value
    fetch_data.pluck(:value).last
  end

  def human_new_value
    number_with_delimiter(number_with_precision(new_value, precision: 0), precision: 4)
  end

  def old_value
    fetch_data.pluck(:value).first
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
