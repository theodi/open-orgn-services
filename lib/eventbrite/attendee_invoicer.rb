class AttendeeInvoicer

  @queue = :invoicing

  # Public: Create an invoice for an event attendee
  #
  # email - The email address of the attendee
  # amount - The monetary amount to be invoiced in GBP
  #
  # Examples
  #
  #   AttendeeInvoicer.perform('james.smith@theodi.org', 0.66)
  #   # => nil
  #
  # Returns nil.
  def self.perform(email, amount)
    puts "invoice #{email} #{amount}"
  end

end