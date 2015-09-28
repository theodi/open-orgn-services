require "active_support/core_ext/string/inflections"

class UpdateMailingList
  @queue = :mailinglist

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
      mailing_list.subscribe(
        email:              member.email,
        level:              member.level,
        contact_first_name: member.contact_first_name,
        contact_last_name:  member.contact_last_name
      )
    else
      mailing_list.unsubscribe(email: member.email)
    end
  rescue MailingList::Failure
    # We don't care at the moment
    false
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

