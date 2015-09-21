require_relative "../lib/mailing_list/mailing_list"

describe MailingList do

  subject do
    MailingList.new(attributes, 1234)
  end

  let(:api)        { double("Mailchimp API") }
  let(:list)       { double("Mailchimp list") }
  let(:attributes) { { email: "test@example.com", level: "supporter" } }

  before do
    subject.api = api
  end

  describe "#subscribe" do

    before do
      allow(api).to receive(:lists).and_return(list)
    end

    context "user does not exist on the Mailchimp list" do
      it "subscribes the user" do
        expect(list).to receive(:subscribe).with(a_hash_including(
          :id           => 1234,
          :email        => { :email => "test@example.com" },
          :merge_vars   => { :LEVEL => "supporter" },
          :double_optin => false
        ))

        subject.subscribe
      end
    end

    context "cannot subscribe the user" do
      it "should raise an exception" do
        allow(list).to receive(:subscribe).and_raise(Gibbon::MailChimpError)

        expect { subject.subscribe }.to raise_error(MailingList::SubscribeFailure)
      end
    end
  end

  describe "#unsubscribe" do

    before do
      allow(api).to receive(:lists).and_return(list)
    end

    context "user already exists on the Mailchimp list" do
      it "unsubscribes the user" do
        expect(list).to receive(:unsubscribe).with(a_hash_including(
          :id            => 1234,
          :email         => { :email => "test@example.com" },
          :delete_member => true,
          :send_notify   => false,
          :send_goodbye  => false
        ))

        subject.unsubscribe
      end
    end

    context "cannot subscribe the user" do
      it "should raise an exception" do
        allow(list).to receive(:unsubscribe).and_raise(Gibbon::MailChimpError)

        expect { subject.unsubscribe }.to raise_error(MailingList::UnsubscribeFailure)
      end
    end
  end
end
