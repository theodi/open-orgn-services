require_relative "../../lib/crm/crm_data"

describe CRM::Data do

  let(:datasource) { double("Actual CRM system") }

  let(:member) { double("Member") }

  let(:type) { :person }

  subject do
    CRM::Data.new(type)
  end

  describe "#datasource" do
    it "should return the datasource name" do
      expect(subject.datasource_name).to eq("CapsuleCRM::Person")
    end
  end

  describe "#find" do
    before do
      subject.datasource = datasource
    end

    it "returns the correct member" do
      expect(datasource).to receive(:find)
        .with(1234).and_return(member)

      person = subject.find(1234)

      expect(person.class).to eq(CRM::Party)
    end
  end
end

