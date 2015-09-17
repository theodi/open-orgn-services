require 'active_support/core_ext/numeric/time'

class SyncMailingList
  @queue = :mailing_list

  def self.perform
    new.perform
  end

  attr_writer :members, :queue

  def perform
    members.each do |member|
      if updated_within_24_hours?(member)
        queue.enqueue(UpdateMailingList, member.id, member.class.to_s.demodulize)
      end
    end
  end

  private

  def updated_within_24_hours?(member)
    member.updated_at > 24.hours.ago
  end

  def queue
    @queue ||= Resque
  end

  def members
    @members ||= CapsuleMembers.all
  end
end

