require 'nokogiri'

class PressMetrics

  @queue = :metrics

  extend MetricsHelper

  def self.perform
    {
      "current-year-press-sentiment"              => sentiment,
      "current-year-press-spokespeople"           => spokespeople,
      "current-year-press-sector-spread"          => sector_spread,
      "current-year-press-geographical-spread"    => geographical_spread,
      "current-year-press-totals"                 => totals,
    }.each_pair do |metric, value|
      store_metric metric, DateTime.now, value
    end
    clear_cache!
  end

  def self.sentiment
    {
      "positive" => data.xpath("//Sentiment/Positive").text.to_i,
      "neutral"  => data.xpath("//Sentiment/Neutral").text.to_i,
      "balanced" => data.xpath("//Sentiment/Balanced").text.to_i,
      "negative" => data.xpath("//Sentiment/Negative").text.to_i,
    }
  end

  def self.spokespeople
    Hash[
      data.xpath("//SpokesPerson").map do |x|
        [x.attributes['id'].value, x.text.to_i]
      end
    ]
  end

  def self.sector_spread
    Hash[
      data.xpath("//Sector").map do |x|
        [x.attributes['id'].value, x.text.to_i]
      end
    ]
  end

  def self.geographical_spread
    Hash[
      data.xpath("//Country").map do |x|
        [x.attributes['id'].value, x.text.to_i]
      end
    ]
  end

  def self.totals
    Hash[
      data.xpath("//Totals/*").map do |x|
        [
          x.name,
          {
            "volume" => x.attributes['Volume'].value.to_i,
            "value" => x.attributes['Value'].value.to_i,
            "reach" => x.attributes['Reach'].value.to_i,
          }
        ]
      end
    ]
  end

  def self.data
    uri = URI.parse(ENV['PRECISEMEDIA_FEED_URL'])
    @@data ||= Nokogiri::XML(Net::HTTP.get(uri))
  end

  def self.clear_cache!
    @@data = nil
  end

end
