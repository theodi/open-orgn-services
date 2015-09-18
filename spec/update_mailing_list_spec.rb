require_relative "../lib/mailing_list/update_mailing_list"

describe UpdateMailingList do

  subject do
    UpdateMailingList.new(id, type)
  end

  let(:id) { 123 }
  let(:type) { "Person" }
  let(:mailing_list) { double("Mailing list") }
  let(:member) { double("Member", email: "test@example.com") }
  let(:crm) { double("CRM") }

  before do
    subject.mailing_list = mailing_list
    subject.crm = crm
  end

  describe "#perform" do

    before do
      allow(crm).to receive(:find).and_return(member)
    end

    context "member doesn't want to receive the newsletter" do
      it "unsubscribes the user from the list" do
        allow(member).to receive(:newsletter?).and_return(true)

        expect(mailing_list).to receive(:subscribe).with(email: "test@example.com")

        subject.perform
      end
    end

    context "member does want to receive the newsletter" do
      it "subscribes the user to the list" do
        allow(member).to receive(:newsletter?).and_return(false)

        expect(mailing_list).to receive(:unsubscribe).with(email: "test@example.com")

        subject.perform
      end
    end
  end
end

