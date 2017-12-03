require 'httparty'

class Providers
  class Triggi
    TRIGGI_CONNECTOR = ENV['TRIGGI_CONNECTOR']

    def send_push_notification
      options = { query: { value: message } }
      HTTParty.post("https://connect.triggi.com/c/#{TRIGGI_CONNECTOR}", options)
    end
end
