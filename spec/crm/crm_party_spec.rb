require_relative "../../lib/crm/crm_party"

describe CRM::Party do

  let(:custom_fields) { [] }

  let(:emails) do
    [
      OpenStruct.new({ address: "test2@example.com" }),
      OpenStruct.new({ address: "test1@example.com" })
    ]
  end

  let(:crm_record) do
    double("CRM Person/Organization",
      emails: emails,
      custom_fields: custom_fields
    )
  end

  subject do
    CRM::Party.new(crm_record)
  end

  describe "#email" do
    it "should return the first email" do
      expect(subject.email).to eq("test2@example.com")
    end

    context "there are no emails" do
      let(:emails) { [] }

      it "should return nil" do
        expect(subject.email).to eq(nil)
      end
    end
  end

  describe "#newsletter?" do
    let(:custom_fields) do
      [OpenStruct.new({ "tag"=>"Membership", "label"=>"Newsletter", "boolean" => true })]
    end

    it "should return true" do
      expect(subject.newsletter?).to eq(true)
    end
  end

  describe "#level" do
    let(:custom_fields) do
      [OpenStruct.new({ "tag"=>"Membership", "label"=>"Level", "text" => "supporter" })]
    end

    it "should return the level" do
      expect(subject.level).to eq("supporter")
    end
  end
end

