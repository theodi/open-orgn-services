require 'csv'
require 'httparty'

class CertificateCount
  @queue = :metrics

  extend MetricsHelper

  def self.odcs(year = nil)
    response = HTTParty.get("https://certificates.theodi.org/status.csv").body
    csv      = CSV.parse(response)
    csv.last[3].to_i
  end

  def self.perform
    store_metric("certificated-datasets", DateTime.now, odcs)
  end
end