class EventSummaryGenerator
  
  @queue = :invoicing
  
  def self.perform(events)
    data = {
      "http://eventbrite.co.uk/..." => {
          "@type" => "http://schema.org/Event",
          "startDate" => "2013-04-29T09:00:00",
          "endDate" => "2013-05-01T17:00:00",
          "location" => {
            "@type" => "http://schema.org/Place",
            "name" => "Covent Garden, London",
            "address" => {
              "@type" => "http://schema.org/PostalAddress",
              "name" => "Wallspace Covent Garden",
              "streetAddress" => "2 Dryden Street",
              "addressLocality" => "Covent Garden",
              "postalCode" => "WC2E 9NA",
              "addressCountry" => "UK"
            },
            "geo" => {
              "latitude" => 51.514495,
              "longitude" => -0.123028
            }
          },
          "offers" => [{
            "@type" => "http://schema.org/Offer",
            "name" => "Standard Registration",
            "price" => 1395.00,
            "priceCurrency" => "GBP",
            "validFrom" => "2013-03-29",
            "inventoryLevel" => 13
          }, {
            "@type" => "http://schema.org/Offer",
            "name" => "Early-Bird Registration",
            "price" => 1255.00,
            "priceCurrency" => "GBP",
            "validThrough" => "2013-03-29",
            "inventoryLevel" => 13
          }]
        }, 
      "http://eventbrite.com/..." => {
        "@type" => "http://schema.org/Event"
      }
    }
    Resque.enqueue(EventSummaryUploader, JSON.pretty_generate(data, :indent => '  '))
  end
  
end