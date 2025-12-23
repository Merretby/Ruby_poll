require "httparty"
require "dotenv/load"

module CurrencyConverter
  VALID_CURRENCIES = ["USD", "EUR", "GBP", "JPY"]
  api_key = ENV['API_KEY']
  api_url = ENV['API_URL']

  module ApiClient
    def make_request(url, params = [])
      response = HTTParty.get(url, query: params)
      
      if (response.success?)
        response.parsed_response
      else
        raise "API request failed: #{response.code} - #{response.message}"
      end
    end
  end

  class Exchanger
    include ApiClient

    def initialize(api_key, api_url)
      @api_key = api_key
      @api_url = api_url
    end

    def convert(amount, from, to)
      validate_currency(from)
      validate_currency(to)
      
      return amount 
    
        if (from == to)      
      rates = fetch_rates
      calculate_conversion(amount, from, to, rates)
    end

    private

    def fetch_rates
      params = @api_key.empty? ? {} : { apikey: @api_key }
      data = make_request(@api_url, params)
      data["rates"] || data
    end

    def calculate_conversion(amount, from, to, rates)
      if from == "USD"
        amount * rates[to]
      elsif to == "USD"
        amount / rates[from]
      else
        usd_amount = amount / rates[from]
        usd_amount * rates[to]
      end
    end

    def validate_currency(currency)
      unless VALID_CURRENCIES.include?(currency)
        raise "Invalid currency code: #{currency}. Supported: #{VALID_CURRENCIES.join(', ')}"
      end
    end
  end
end

exchanger = CurrencyConverter::Exchanger.new(ENV['API_KEY'], ENV['API_URL'])
result = exchanger.convert(100, "EUR", "JPY")
puts "100 EUR = #{result.round(2)} JPY"
