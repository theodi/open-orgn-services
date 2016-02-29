# TODO This is temporary until we inject the
# dependency at which point we will use a test
# double instead
Resque   = Class.new { def self.enqueue(*args); end }
Invoicer = Class.new

require_relative "../../lib/signup/signup_processor"

describe SignupProcessor do
  subject do
    SignupProcessor.new(organization, contact_person, billing, purchase)
  end

  let(:organization_name) { "Mr Test" }

  let(:organization_type) {}

  let(:size) { "10-50" }

  let(:organization) do
    {
      "name"           => organization_name,
      "company_number" => "123456",
      "size"           => size,
      "sector"         => "Education",
      "origin"         => "odi-leeds",
      "type"           => organization_type
    }
  end

  let(:contact_person) do
    {
      "name"                           => "Contact person",
      "email"                          => "contact@person.com",
      "twitter"                        => "@twitter",
      "dob"                            => "DOB",
      "university_email"               => "uni-email@example.com",
      "university_address_country"     => "Uni address country",
      "university_country"             => "Uni country",
      "university_name"                => "Uni name",
      "university_name_other"          => "Uni name other",
      "university_course_name"         => "Uni course name",
      "university_qualification"       => "Uni qualification",
      "university_qualification_other" => "Uni qualification other",
      "university_course_start_date"   => "Uni course start date",
      "university_course_end_date"     => "Uni course end date"
    }
  end

  let(:billing) do
    {
      "name" => "Billing person",
      "email" => "test@example.com",
      "telephone" => "01234 567890",
      "address" => {
        "street_address"   => "1 Some Street",
        "address_locality" => "Some town",
        "address_region"   => "Some region",
        "address_country"  => "Some country",
        "postal_code"      => "Some postcode"
      },
      "coupon" => "COUPON"
    }
  end

  let(:category) { "individual" }

  let(:purchase) do
    {
      "offer_category"           => category,
      "membership_id"            => 123456,
      "payment_method"           => "credit_card",
      "payment_freq"             => "annual",
      "payment_ref"              => "012345",
      "discount"                 => 50.0,
      "purchase_order_reference" => "PO1234"
    }
  end

  describe "#perform" do
    let(:expected_organization_details_name) { "Mr Test" }

    let(:expected_organization_details) do
      {
        "name"            => expected_organization_details_name,
        "contact_name"    => "Contact person",
        "company_number"  => "123456",
        "email"           => "test@example.com"
      }
    end

    let(:expected_membership_details) do
      {
        "product_name"                   => "individual",
        "supporter_level"                => "Individual",
        "id"                             => "123456",
        "join_date"                      => Date.today.to_s, # Not ideal, but no times so should ok?
        "contact_email"                  => "contact@person.com",
        "twitter"                        => "@twitter",
        "size"                           => "10-50",
        "sector"                         => "Education",
        "origin"                         => "odi-leeds",
        "coupon"                         => "COUPON",
        "dob"                            => "DOB",
        "university_email"               => "uni-email@example.com",
        "university_address_country"     => "Uni address country",
        "university_country"             => "Uni country",
        "university_name"                => "Uni name",
        "university_name_other"          => "Uni name other",
        "university_course_name"         => "Uni course name",
        "university_qualification"       => "Uni qualification",
        "university_qualification_other" => "Uni qualification other",
        "university_course_start_date"   => "Uni course start date",
        "university_course_end_date"     => "Uni course end date"
      }
    end

    let(:expected_invoice_to_name) { "Mr Test" }

    let(:expected_invoice_to) do
      {
        "name" => expected_invoice_to_name,
        "contact_point" => {
          "name"      => "Billing person",
          "email"     => "test@example.com",
          "telephone" => "01234 567890"
        },
        "address" => {
          "street_address"   => "1 Some Street",
          "address_locality" => "Some town",
          "address_region"   => "Some region",
          "address_country"  => "Some country",
          "postal_code"      => "Some postcode"
        }
      }
    end

    let(:expected_invoice_line_item_description) do
      "ODI Individual supporter (123456) [Individual] (annual card payment)"
    end

    let(:expected_invoice_details) do
      {
        "payment_method" => "credit_card",
        "payment_ref" => "012345",
        "line_items" => [
          {
            "quantity"      => 1,
            "base_price"    => 90,
            "discount_rate" => 50.0,
            "description"   => expected_invoice_line_item_description
          }
        ],
        "repeat"                   => "annual",
        "purchase_order_reference" => "PO1234",
        "sector"                   => "Education"
      }
    end

    it "should save the signup details to the CRM" do
      expect(SendSignupToCapsule).to receive(:perform).with(
        expected_organization_details, expected_membership_details
      ).once

      expect(Resque).to receive(:enqueue).with(
        Invoicer, expected_invoice_to, expected_invoice_details
      ).once

      subject.perform
    end

    context "organization name is empty" do
      let(:organization_name) { nil }

      let(:expected_organization_details_name) { "Contact person" }
      let(:expected_invoice_to_name) { "Contact person" }

      it "should save the signup details to the CRM" do
        expect(SendSignupToCapsule).to receive(:perform).with(
          expected_organization_details, expected_membership_details
        ).once

        expect(Resque).to receive(:enqueue).with(
          Invoicer, expected_invoice_to, expected_invoice_details
        ).once

        subject.perform
      end
    end

    context "organization type is empty" do
      let(:organization_type) { "non_commercial" }

      let(:expected_invoice_line_item_description) do
        "ODI Individual supporter (123456) [Non Commercial] (annual card payment)"
      end

      it "should save the signup details to the CRM" do
        expect(SendSignupToCapsule).to receive(:perform).with(
          expected_organization_details, expected_membership_details
        ).once

        expect(Resque).to receive(:enqueue).with(
          Invoicer, expected_invoice_to, expected_invoice_details
        ).once

        subject.perform
      end
    end

    context "individual signing up with flexible pricing" do
      let(:category) { 'individual' }

      let(:expected_invoice_line_item_description) do
        "ODI Individual supporter (123456) [Individual] (annual card payment)"
      end

      let(:purchase) do
        {
          "offer_category"           => category,
          "membership_id"            => 123456,
          "payment_method"           => "credit_card",
          "payment_freq"             => "annual",
          "payment_ref"              => "012345",
          "discount"                 => 0,
          "purchase_order_reference" => "PO1234",
          "amount_paid"              => 5
        }
      end

      let(:expected_invoice_details) do
        {
          "payment_method" => "credit_card",
          "payment_ref" => "012345",
          "line_items" => [
            {
              "quantity"      => 1,
              "base_price"    => 5,
              "discount_rate" => 0,
              "description"   => expected_invoice_line_item_description
            }
          ],
          "repeat"                   => "annual",
          "purchase_order_reference" => "PO1234",
          "sector"                   => "Education"
        }
      end

      it "should save the signup details to the CRM" do
        expect(SendSignupToCapsule).to receive(:perform).with(
          expected_organization_details, expected_membership_details
        ).once

        expect(Resque).to receive(:enqueue).with(
          Invoicer, expected_invoice_to, expected_invoice_details
        ).once

        subject.perform
      end
    end
  end

  describe "#membership_type" do
    let(:size) { }
    let(:type) { }
    let(:category) { }

    context "individual" do
      let(:category) { "individual" }

      it "returns the details for individual supporters" do
        expect(subject.membership_type).to eq({
          price:       90,
          description: "Individual supporter",
          type:        "Individual"
        })
      end
    end

    context "corporate supporter" do
      let(:category) { "corporate" }

      it "returns the details for corporate supporters" do
        expect(subject.membership_type).to eq({
          price:       2200,
          description: "Corporate Supporter",
          type:        "Corporate supporter"
        })
      end
    end

    context "non-commercial supporter" do
      let(:organization_type) { "non_commercial" }

      it "returns the details for supporters" do
        expect(subject.membership_type).to eq({
          price:       720,
          description: "Supporter",
          type:        "Supporter"
        })
      end
    end

    context "supporter with valid organisation size" do
      let(:size) { "10-50" }

      it "returns the details for supporters" do
        expect(subject.membership_type).to eq({
          price:       720,
          description: "Supporter",
          type:        "Supporter"
        })
      end
    end
  end

  describe "#invoice_description" do
    let(:membership_id) { "12345" }
    let(:description) { "Individual supporter" }
    let(:type) { "individual" }
    let(:frequency) { "annual" }
    let(:method) { "credit_card" }

    it "returns the correct description" do
      expect(subject.invoice_description(membership_id, description, type, method, frequency)).to eq(
        "ODI Individual supporter (12345) [Individual] (annual card payment)"
      )
    end
  end

  describe "#format_payment_method" do
    context "payment method is credit card" do
      let(:payment_method) { "credit_card" }

      it "returns 'card'" do
        expect(subject.format_payment_method(payment_method)).to eq("card")
      end
    end

    context "payment method is direct debit" do
      let(:payment_method) { "direct_debit" }

      it "returns 'direct_debit'" do
        expect(subject.format_payment_method(payment_method)).to eq("dd")
      end
    end

    context "payment method is something else" do
      let(:payment_method) { "invoice" }

      it "returns what was passed in" do
        expect(subject.format_payment_method(payment_method)).to eq("invoice")
      end
    end
  end
end
