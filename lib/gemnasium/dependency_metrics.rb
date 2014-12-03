require 'curb'

class DependencyMetrics
  
  @queue = :metrics
  
  extend MetricsHelper
  
  def self.dependencies
    # Get gemnasium page
    response = Curl.get("https://gemnasium.com/#{ENV['GITHUB_ORGANISATION']}").body_str
    doc = Nokogiri::HTML(response)
    {
      current: sum_values(doc, ".runtime-dependencies .green .chart") + 
               sum_values(doc, ".development-dependencies .green .chart"),
      warning: sum_values(doc, ".runtime-dependencies .yellow .chart") + 
               sum_values(doc, ".development-dependencies .yellow .chart"),
      danger:  sum_values(doc, ".runtime-dependencies .red .chart") + 
               sum_values(doc, ".development-dependencies .red .chart"),
      alerts:  sum_values(doc, "footer.box span.counter"),
    }
  end
  
  def self.perform
    store_metric('gemnasium-dependencies', Time.now, dependencies)
  end
  
  def self.sum_values(doc, selector)
    doc.css(selector).inject(0){|sum, node| sum += node.text.to_i}
  end
  
end