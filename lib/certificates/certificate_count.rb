require 'json'
require 'httparty'

class CertificateCount
  @queue = :metrics

  extend MetricsHelper

  def self.odcs(year = nil)
    response = HTTParty.get("https://certificates.theodi.org/datasets/info.json")
    info = JSON.parse(response.body)
    info['published_certificate_count'].to_i
  end

  def self.perform
    store_metric("certificated-datasets", DateTime.now, odcs)
  end
end
