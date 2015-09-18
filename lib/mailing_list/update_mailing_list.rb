require "active_support/core_ext/string/inflections"

class UpdateMailingList
  @queue = :mailing_list

  def self.perform(id, type)
    new(id, type).perform
  end

  attr_writer :mailing_list, :crm
  attr_reader :id

  def initialize(id, type)
    @id   = id
    @type = type
  end

  def perform
    if member.newsletter?
      mailing_list.subscribe(email: member.email, level: member.level)
    else
      mailing_list.unsubscribe(email: member.email)
    end
  end

  private

  def member
    @member ||= crm.find(type, id)
  end

  def type
    @type.to_sym
  end

  def crm
    @crm ||= CRM::Data
  end

  def mailing_list
    @mailing_list ||= MailingList
  end
end

