require 'active_support/core_ext/numeric/time'

class SyncMailingList
  @queue = :mailinglist

  def self.perform
    new.perform
  end

  attr_writer :members, :queue
  attr_reader :since

  def initialize(since = 24.hours.ago)
    @since = since
  end

  def perform
    members.each do |member|
      if requires_update?(member)
        queue.enqueue(UpdateMailingList, member.id, member.class.to_s.demodulize)
      end
    end
  end

  private

  def requires_update?(member)
    member.updated_at > since
  end

  def queue
    @queue ||= Resque
  end

  def members
    @members ||= CapsuleMembers.all
  end
end

