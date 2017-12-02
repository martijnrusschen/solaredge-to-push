include ActionView::Helpers::NumberHelper

class SolarEdgeFetcher
  SITE = ENV['SOLAREDGE_SITE']

  def fetch_data
    @start_date = Time.now-31.days
    @end_date = Time.now-1.day

    raw_data = SolarEdge::Site.new(client, SITE).energy(
      resolution: :day,
      start_date: @start_date,
      end_date: @end_date
    )

    values = raw_data.pluck(:value)
    average = values.sum / values.size.to_f

    {
      average: value_to_human(average),
      yesterday: value_to_human(values.last),
      difference_in_percentage: difference_in_percentage(average, values.last)
    }
  end

  private

  def client
    SolarEdge::Client.new(ENV['SOLAREDGE_KEY'])
  end

  def value_to_human(value)
    value = value/1_000
    number_with_precision(value, precision: 2)
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

    difference
  end
end
