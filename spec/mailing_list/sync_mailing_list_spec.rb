require_relative "../../lib/mailing_list/sync_mailing_list"

UpdateMailingList = Class.new

describe SyncMailingList do

  subject do
    SyncMailingList.new
  end

  describe "#perform" do
    let(:queue) { double("Job Queue") }

    let(:members) do
      [
        double(class: "CapsuleCRM::Organisation", id: 1, updated_at: 24.hours.ago + 1.second),
        double(class: "CapsuleCRM::Organisation", id: 2, updated_at: 25.hours.ago),
        double(class: "CapsuleCRM::Person",       id: 3, updated_at: 2.hours.ago)
      ]
    end

    before do
      subject.members = members
      subject.queue   = queue
    end

    it "should only queue members updated in the last 24 hours" do
      expect(queue).to     receive(:enqueue).with(UpdateMailingList, 1, "Organisation")
      expect(queue).to_not receive(:enqueue).with(UpdateMailingList, 2, "Organisation")
      expect(queue).to     receive(:enqueue).with(UpdateMailingList, 3, "Person")

      subject.perform
    end
  end
end

