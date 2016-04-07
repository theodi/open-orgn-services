require_relative "../../lib/mailing_list/sync_mailing_list"

describe SyncMailingList do

  subject do
    SyncMailingList.new
  end

  describe "#perform" do
    let(:queue) { double("Job Queue") }

    let(:members) do
      [
        double(class: "CapsuleCRM::Organisation", id: 1),
        double(class: "CapsuleCRM::Organisation", id: 2),
        double(class: "CapsuleCRM::Person",       id: 3)
      ]
    end

    before do
      subject.members = members
      subject.queue   = queue
    end

    it "should queue members for processing" do
      expect(queue).to receive(:enqueue).with(UpdateMailingList, 1, "Organisation")
      expect(queue).to receive(:enqueue).with(UpdateMailingList, 2, "Organisation")
      expect(queue).to receive(:enqueue).with(UpdateMailingList, 3, "Person")

      subject.perform
    end
  end
end

