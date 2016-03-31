# encoding: utf-8

require "open-orgn-services"

describe OrderInvoicer do
  before do
    allow(Eventbrite::Client).to receive(:order_details).with(order_uri).and_return(order_details)
  end

  it "sends details to the Invoicer task" do
    expect(Resque).to receive(:enqueue).with(
      Invoicer,
      expected_invoice_to,
      hash_including(expected_invoice_details),
      expected_invoice_id)
    OrderInvoicer.perform(order_uri)
  end

  let(:order_uri) { "https://www.eventbriteapi.com/v3/orders/63599200/" }

  let(:expected_invoice_to) do
    {
      "name" => "Company Com",
      "contact_point" => {
        "name" => "Penny Collins",
        "email" => "jfish@company.com",
        "telephone" => "123 456 789"
      },
      "address" => {
        "street_address" => "Company Com, 14 Street Road",
        "address_locality" => "Cityland",
        "address_region" => "Areatown",
        "address_country" => "England",
        "postal_code" => "PC1 0PP"
      },
      "vat_id" => "VAT123"
    }
  end
  let(:expected_invoice_details) do
    {
      "line_items" => [
        {
          "base_price" => 26950,
          "description" => "Ticket name for 'name (2015-11-30)' for Penny Collins <pcollins@company.com> Order number: 63599200, Membership number: 123"
        }
      ],
      "purchase_order_reference" => "123456",
      "due_date" => "2015-11-23",
      "sector" => "Third sector (eg. charities, non-profits)"
    }
  end
  let(:expected_invoice_id) { "eventbrite:event:5994233182:invoice:63599200" }

  let(:order_details) do
    JSON.parse(<<-JSON)
      {
        "resource_uri": "https://www.eventbriteapi.com/v3/orders/63599200/",
        "id": "63599200",
        "changed": "2015-10-14T10:27:52Z",
        "created": "2015-10-14T10:27:51Z",
        "costs": {
          "payment_fee": {
            "currency": "GBP",
            "display": "£0.00",
            "value": 0
          },
          "gross": {
            "currency": "GBP",
            "display": "£331.20",
            "value": 33120
          },
          "eventbrite_fee": {
            "currency": "GBP",
            "display": "£6.50",
            "value": 650
          },
          "tax": {
            "currency": "GBP",
            "display": "£55.20",
            "value": 5520
          },
          "base_price": {
            "currency": "GBP",
            "display": "£269.50",
            "value": 26950
          }
        },
        "name": "Jenny Fish",
        "first_name": "Jenny",
        "last_name": "Fish",
        "email": "jfish@company.com",
        "status": "placed",
        "time_remaining": null,
        "event_id": "5994233182",
        "attendees": [
          {
            "team": null,
            "resource_uri": "https://www.eventbriteapi.com/v3/events/5994233182/attendees/585498700/",
            "id": "585498700",
            "changed": "2015-10-14T10:27:52Z",
            "created": "2015-10-14T10:27:51Z",
            "quantity": 1,
            "profile": {
              "website": "http://company.com",
              "first_name": "Penny",
              "last_name": "Collins",
              "addresses": {
                "home": {},
                "ship": {},
                "work": {},
                "bill": {}
              },
              "company": "Company Com",
              "name": "Penny Collins",
              "email": "pcollins@company.com",
              "job_title": "Chief Executive"
            },
            "barcodes": [
              {
                "status": "unused",
                "barcode": "463599200585498700001",
                "checkin_type": 0,
                "created": "2015-10-14T10:27:52Z",
                "changed": "2015-10-14T10:27:52Z"
              }
            ],
            "answers": [
              {
                "answer": "Company Com",
                "question": "Billing Address (line 1)",
                "type": "text",
                "question_id": "9562046"
              },
              {
                "answer": "14 Street Road",
                "question": "Billing Address (line 2)",
                "type": "text",
                "question_id": "9562047"
              },
              {
                "answer": "Cityland",
                "question": "Billing Address (city)",
                "type": "text",
                "question_id": "9562048"
              },
              {
                "answer": "Areatown",
                "question": "Billing Address (region)",
                "type": "text",
                "question_id": "9562049"
              },
              {
                "answer": "England",
                "question": "Billing Address (country)",
                "type": "text",
                "question_id": "9562050"
              },
              {
                "answer": "PC1 0PP",
                "question": "Billing Address (postcode)",
                "type": "text",
                "question_id": "9562051"
              },
              {
                "answer": "jfish@company.com",
                "question": "Billing Email",
                "type": "text",
                "question_id": "9562052"
              },
              {
                "answer": "123 456 789",
                "question": "Billing Phone Number",
                "type": "text",
                "question_id": "9562053"
              },
              {
                "answer": "VAT123",
                "question": "VAT reg number (if non-UK)",
                "type": "text",
                "question_id": "9562054"
              },
              {
                "answer": "123456",
                "question": "Purchase Order Number",
                "type": "text",
                "question_id": "9562056"
              },
              {
                "question": "Dietary Requirements",
                "type": "text",
                "question_id": "9562057"
              },
              {
                "question": "Accessibility Requirements",
                "type": "text",
                "question_id": "9562058"
              },
              {
                "question": "Charity number (if applicable)",
                "type": "text",
                "question_id": "9562059"
              },
              {
                "answer": "Third sector (eg. charities, non-profits)",
                "question": "Sector",
                "type": "multiple_choice",
                "question_id": "9562063"
              },
              {
                "question": "Members must accept this waiver in order to register for the course. ",
                "type": "text",
                "question_id": "9562064"
              },
              {
                "answer": "Accepted",
                "question": "Please accept this waiver in order to register for the course.",
                "type": "text",
                "question_id": "9816703"
              },
              {
                "answer": "123",
                "question": "Membership Number",
                "type": "text",
                "question_id": "9816709"
              }
            ],
            "costs": {
              "payment_fee": {
                "currency": "GBP",
                "display": "£0.00",
                "value": 0
              },
              "gross": {
                "currency": "GBP",
                "display": "£331.20",
                "value": 33120
              },
              "eventbrite_fee": {
                "currency": "GBP",
                "display": "£6.50",
                "value": 650
              },
              "tax": {
                "currency": "GBP",
                "display": "£55.20",
                "value": 5520
              },
              "base_price": {
                "currency": "GBP",
                "display": "£269.50",
                "value": 26950
              }
            },
            "checked_in": false,
            "cancelled": false,
            "refunded": false,
            "affiliate": null,
            "status": "Attending",
            "event_id": "5994233182",
            "order_id": "63599200",
            "ticket_class_id": "34093208"
          }
        ],
        "event": {
          "name": {
            "text": "name",
            "html": "name"
          },
          "description": {
            "text": "description",
            "html": "description"
          },
          "id": "5994233182",
          "url": "http://www.eventbrite.co.uk/e/name-tickets-5994233182",
          "start": {
            "timezone": "Europe/London",
            "local": "2015-11-30T09:15:00",
            "utc": "2015-11-30T09:15:00Z"
          },
          "end": {
            "timezone": "Europe/London",
            "local": "2015-11-30T17:00:00",
            "utc": "2015-11-30T17:00:00Z"
          },
          "created": "2015-03-03T13:54:04Z",
          "changed": "2015-11-02T10:45:00Z",
          "capacity": 16,
          "status": "live",
          "currency": "GBP",
          "listed": true,
          "shareable": true,
          "invite_only": false,
          "online_event": false,
          "show_remaining": false,
          "tx_time_limit": 480,
          "hide_start_date": false,
          "locale": "en_GB",
          "logo_id": "12546103",
          "organizer_id": "2830918680",
          "venue_id": "4894373",
          "category_id": null,
          "subcategory_id": null,
          "format_id": "9",
          "resource_uri": "https://www.eventbriteapi.com/v3/events/5994233182/",
          "ticket_classes": [
            {
              "resource_uri": "https://www.eventbriteapi.com/v3/events/5994233182/ticket_classes/34093208/",
              "id": "34093208",
              "name": "Ticket name",
              "description": "",
              "cost": {
                "currency": "GBP",
                "display": "£276.00",
                "value": 27600
              },
              "fee": {
                "currency": "GBP",
                "display": "£0.00",
                "value": 0
              },
              "tax": {
                "currency": "GBP",
                "display": "£55.20",
                "value": 5520
              },
              "actual_cost": {
                "currency": "GBP",
                "display": "£269.50",
                "value": 26950
              },
              "actual_fee": {
                "currency": "GBP",
                "display": "£6.50",
                "value": 650
              },
              "donation": false,
              "free": false,
              "minimum_quantity": 1,
              "maximum_quantity": 4,
              "maximum_quantity_per_order": 4,
              "on_sale_status": "AVAILABLE",
              "quantity_total": 16,
              "quantity_sold": 3,
              "sales_start": "2015-03-02T09:00:00Z",
              "sales_end": "2015-11-27T12:00:00Z",
              "hidden": false,
              "include_fee": true,
              "split_fee": false,
              "hide_description": false,
              "auto_hide": false,
              "variants": [],
              "has_pdf_ticket": true,
              "event_id": "5994233182"
            }
          ]
        }
      }
    JSON
  end
end
