require_relative "../../lib/mailing_list/mailing_list"
require_relative "../../lib/mailing_list/update_mailing_list"

describe UpdateMailingList do

  subject do
    UpdateMailingList.new(id, type)
  end

  let(:id) { 123 }
  let(:type) { "Person" }
  let(:mailing_list) { double("Mailing list") }
  let(:member) do
    double("Member",
      email: "test@example.com",
      level: "supporter",
      supporter_level: "Individual",
      contact_first_name: "Test",
      contact_last_name: "Example",
      country: "United Kingdom",
      twitter: "@twitter",
      join_date: "07/10/2015",
      organization_sector: "Sector",
      organization_name: "Organization name",
      organization_size: "<1000"
    )
  end
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

        expect(mailing_list).to receive(:subscribe)
          .with(
            email: "test@example.com",
            level: "supporter",
            supporter_level: "Individual",
            contact_first_name: "Test",
            contact_last_name: "Example",
            country: "United Kingdom",
            twitter: "@twitter",
            join_date: "07/10/2015",
            organization_sector: "Sector",
            organization_name: "Organization name",
            organization_size: "<1000"
          )

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

    context "cannot subscribe or unsubscribe" do
      it "should return false" do
        allow(member).to receive(:newsletter?).and_return(true)
        allow(mailing_list).to receive(:subscribe).and_raise(MailingList::Failure)

        expect(subject.perform).to eq(false)
      end
    end
  end
end

