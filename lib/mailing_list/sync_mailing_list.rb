require 'active_support/core_ext/numeric/time'

class SyncMailingList
  @queue = :mailinglist

  def self.perform
    new.perform
  end

  attr_writer :members, :queue

  def perform
    members.each do |member|
      queue.enqueue(UpdateMailingList, member.id, member.class.to_s.demodulize)
    end
  end

  private

  def queue
    @queue ||= Resque
  end

  def members
    @members ||= CapsuleMembers.all
  end
end

