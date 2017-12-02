class SolarCollector
  def post_to_slack
    Providers::Slack.post_to_slack(message, @new_value, @average)
  end

  def send_push_notification
    Providers::Triggi.send_push_notification(message)
  end

  private

  def fetch_data
    data = SolarEdgeFetcher.new.fetch_data

    @average = data[:average]
    @new_value = data[:yesterday]
    @difference_in_percentage = data[:difference_in_percentage]
  end

  def message
    fetch_data

    if @difference_in_percentage >= 0
      difference_label = 'higher'
    else
      difference_label = 'lower'
    end

    "Hi Martijn, yesterday your solar panels generated #{value_to_human(@new_value)}" +
    "kWh. That's #{difference_in_percentage}% #{difference_label} compared " +
    "to the average of the last 30 days."
  end
end
