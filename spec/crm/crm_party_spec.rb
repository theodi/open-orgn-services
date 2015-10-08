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

  describe "#contact_first_name" do
    context "membership tag fields are missing" do
      let(:custom_fields) { [] }

      before do
        allow(crm_record).to receive(:first_name).and_return("Arnold")
      end

      it "should return the first name" do
        expect(subject.contact_first_name).to eq("Arnold")
      end
    end

    context "membership tag fields are present" do
      let(:custom_fields) do
        [OpenStruct.new({ "tag"=>"Membership", "label"=>"Contact first name", "text" => "Joe" })]
      end

      it "should return the first name" do
        expect(subject.contact_first_name).to eq("Joe")
      end
    end
  end

  describe "#contact_last_name" do
    context "membership tag fields are missing" do
      let(:custom_fields) { [] }

      before do
        allow(crm_record).to receive(:last_name).and_return("Rimmer")
      end

      it "should return the last name" do
        expect(subject.contact_last_name).to eq("Rimmer")
      end
    end

    context "membership tag fields are present" do
      let(:custom_fields) do
        [OpenStruct.new({ "tag"=>"Membership", "label"=>"Contact last name", "text" => "Bloggs" })]
      end

      it "should return the last name" do
        expect(subject.contact_last_name).to eq("Bloggs")
      end
    end
  end

  describe "#country" do
    context "membership tag fields are missing" do
      let(:custom_fields) { [] }

      it "should return nil" do
        expect(subject.country).to be_nil
      end
    end

    context "membership tag fields are present" do
      let(:custom_fields) do
        [OpenStruct.new({ "tag"=>"Membership", "label"=>"Country", "text" => "United Kingdom" })]
      end

      it "should return the country" do
        expect(subject.country).to eq("United Kingdom")
      end
    end
  end

  describe "#twitter" do
    context "membership tag fields are missing" do
      let(:custom_fields) { [] }

      it "should return nil" do
        expect(subject.twitter).to be_nil
      end
    end

    context "membership tag fields are present" do
      let(:custom_fields) do
        [OpenStruct.new({ "tag"=>"Membership", "label"=>"Twitter", "text" => "@twitter" })]
      end

      it "should return the twitter handle" do
        expect(subject.twitter).to eq("@twitter")
      end
    end
  end

  describe "#join_date" do
    context "membership tag fields are missing" do
      let(:custom_fields) { [] }

      it "should return nil" do
        expect(subject.join_date).to be_nil
      end
    end

    context "membership tag fields are present" do
      let(:custom_fields) do
        [OpenStruct.new({ "tag"=>"Membership", "label"=>"Joined", "date" => Date.parse("2015/01/01") })]
      end

      it "should return the join date" do
        expect(subject.join_date.to_s).to eq("2015-01-01")
      end
    end
  end

  describe "#organization_sector" do
    context "membership tag fields are missing" do
      let(:custom_fields) { [] }

      it "should return nil" do
        expect(subject.organization_sector).to be_nil
      end
    end

    context "membership tag fields are present" do
      let(:custom_fields) do
        [OpenStruct.new({ "tag"=>"Membership", "label"=>"Sector", "text" => "Health" })]
      end

      it "should return the organization sector" do
        expect(subject.organization_sector).to eq("Health")
      end
    end
  end

  describe "#organization_name" do
    context "the crm record is an organization" do
      before do
        allow(crm_record).to receive(:name).and_return("Foobar Inc")
      end

      it "should return the name" do
        expect(subject.organization_name).to eq("Foobar Inc")
      end
    end

    context "the crm record is an person" do
      it "should returns nil" do
        expect(subject.organization_name).to be_nil
      end
    end
  end

  describe "#organization_size" do
    context "membership tag fields are missing" do
      let(:custom_fields) { [] }

      it "should return nil" do
        expect(subject.organization_size).to be_nil
      end
    end

    context "membership tag fields are present" do
      let(:custom_fields) do
        [OpenStruct.new({ "tag"=>"Membership", "label"=>"Size", "text" => ">1000" })]
      end

      it "should return the organization size" do
        expect(subject.organization_size).to eq(">1000")
      end
    end
  end
end

