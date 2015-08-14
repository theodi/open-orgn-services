require "active_support/inflector"

require_relative "../lib/signup/signup_processor"

describe SignupProcessor do
  subject do
    SignupProcessor.new(organization, contact_person, billing, purchase)
  end

  let(:organization) {}

  let(:contact_person) {}

  let(:billing) {}

  let(:purchase) {}

  describe "#membership_type" do
    let(:size) { }
    let(:type) { }
    let(:category) { }

    context "individual" do
      let(:category) { "individual" }

      it "returns the details for individual supporters" do
        expect(subject.membership_type(size, type, category)).to eq({
          price:       108,
          description: "Individual supporter",
          type:        "Individual"
        })
      end
    end

    context "corporate supporter" do
      let(:category) { "corporate" }

      it "returns the details for corporate supporters" do
        expect(subject.membership_type(size, type, category)).to eq({
          price:       2200,
          description: "Corporate Supporter",
          type:        "Corporate supporter"
        })
      end
    end

    context "non-commercial supporter" do
      let(:type) { "non_commercial" }

      it "returns the details for supporters" do
        expect(subject.membership_type(size, type, category)).to eq({
          price:       720,
          description: "Supporter",
          type:        "Supporter"
        })
      end
    end

    context "supporter with valid organisation size" do
      let(:size) { "10-50" }

      it "returns the details for supporters" do
        expect(subject.membership_type(size, type, category)).to eq({
          price:       720,
          description: "Supporter",
          type:        "Supporter"
        })
      end
    end
  end

  describe "#description" do
    let(:membership_id) { "12345" }
    let(:description) { "Individual supporter" }
    let(:type) { "individual" }
    let(:frequency) { "annual" }

    context "payment method is credit card" do
      let(:method) { "credit_card" }

      it "returns the correct description" do
        expect(subject.description(membership_id, description, type, method, frequency)).to eq(
          "ODI Individual supporter (12345) [Individual] (annual card payment)"
        )
      end
    end

    context "payment method is direct debit" do
      let(:method) { "direct_debit" }

      it "returns the correct description" do
        expect(subject.description(membership_id, description, type, method, frequency)).to eq(
          "ODI Individual supporter (12345) [Individual] (annual dd payment)"
        )
      end
    end

    context "payment method is something other than credit card or direct debit" do
      let(:method) { "invoice" }

      it "returns the correct description" do
        expect(subject.description(membership_id, description, type, method, frequency)).to eq(
          "ODI Individual supporter (12345) [Individual] (annual invoice payment)"
        )
      end
    end
  end
end

