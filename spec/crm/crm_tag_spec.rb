require_relative "../../lib/crm/crm_tag"

describe CRM::Tag do

  let(:record) do
    double(
      custom_fields: [
        custom_field
      ]
    )
  end

  let(:type)  {}
  let(:tag)   {}
  let(:label) {}

  subject do
    CRM::Tag.new(record, type, tag, label)
  end

  describe "#value" do
    let(:tag) { "Membership" }

    context "boolean value" do
      let(:label) { "Newsletter" }
      let(:type)  { :boolean }

      let(:custom_field) do
        double(tag: "Membership", label: "Newsletter", boolean: true)
      end

      it "returns the value" do
        expect(subject.value).to eq(true)
      end
    end

    context "text value" do
      let(:label) { "Level" }
      let(:type)  { :text }

      let(:custom_field) do
        double(tag: "Membership", label: "Level", text: "supporter")
      end

      it "returns the value" do
        expect(subject.value).to eq("supporter")
      end
    end

    context "date value" do
      let(:label) { "Joined" }
      let(:type)  { :date }

      let(:custom_field) do
        double(tag: "Membership", label: "Joined", date: Date.parse("01/01/2015"))
      end

      it "returns the value" do
        expect(subject.value.to_s).to eq("2015-01-01")
      end
    end

    context "tag does not exist" do
      let(:tag) { "DoesNotExist" }
      let(:label) { "Dunno" }
      let(:type) { :boolean }

      let(:custom_field) do
        double(tag: "Exists", label: "Foo", boolean: true)
      end

      it "returns nil" do
        expect(subject.value).to eq(nil)
      end
    end

    context "tag exists but field does not" do
      let(:label) { "Dunno" }
      let(:type)  { :text }

      let(:custom_field) do
        double(tag: "Membership", label: "Foo", text: "Bar")
      end

      it "returns nil" do
        expect(subject.value).to eq(nil)
      end
    end

    context "tag exists but field does not and block has been supplied" do
      let(:custom_field) do
        double(tag: "Membership", label: "Nope", text: "Nope")
      end

      it "returns runs the block" do
        expect(subject.value { "Block value" } ).to eq("Block value")
      end
    end
  end
end

