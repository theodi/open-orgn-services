require_relative "../lib/mailing_list/mailing_list"

describe MailingList do

  subject do
    MailingList.new(attributes, 1234)
  end

  let(:api)        { double("Mailchimp API") }
  let(:list)       { double("Mailchimp list") }
  let(:attributes) { { email: "test@example.com" } }

  before do
    subject.api = api
  end

  describe "#subscribe" do
    it "subscribes the user" do
      allow(api).to receive(:lists).and_return(list)

      expect(list).to receive(:subscribe).with(a_hash_including(
        :id           => 1234,
        :email        => { :email => "test@example.com" },
        :double_optin => false
      ))

      subject.subscribe
    end
  end

  describe "#unsubscribe" do
    it "unsubscribes the user" do
      allow(api).to receive(:lists).and_return(list)

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
end
