require "helpers"

RSpec.configure do |c|
  c.include Helpers
end

require_relative "../../lib/mailing_list/mailing_list"

describe MailingList do

  subject do
    MailingList.new(attributes, list_id)
  end

  let(:api)        { double("Mailchimp API") }
  let(:list)       { double("Mailchimp list") }
  let(:list_id)    { 1234 }
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
          :merge_vars   => { :FNAME => "", :LNAME => "", :LEVEL => "supporter" },
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

  describe "#api_key" do
    let(:api_key) { nil }

    around(:each) do |example|
      remove_env_var("MAILCHIMP_API_KEY") do
        example.run
      end
    end

    it "should raise an exception if the Mailchimp API key is missing" do
      expect { subject.api_key }.to raise_error(ArgumentError, "MAILCHIMP_API_KEY is missing")
    end
  end

  describe "#list_id" do
    let(:list_id) { nil }

    around(:each) do |example|
      remove_env_var("MAILCHIMP_LIST_ID") do
        example.run
      end
    end

    it "should raise an exception if the Mailchimp List ID is missing" do
      expect { subject.list_id }.to raise_error(ArgumentError, "MAILCHIMP_LIST_ID is missing")
    end
  end
end
