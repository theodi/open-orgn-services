class AttendeeInvoicer

  @queue = :invoicing

  # Public: Create an invoice for an event attendee
  #
  # user_details    - a hash containing details of the user.
  #                   :email - the user's email address
  # event_details   - a hash containing the details of the event.
  #                   :id - the eventbrite ID
  # payment_details - a hash containing payment details.
  #                   :amount - The monetary amount to be invoiced in GBP
  #
  # Examples
  #
  #   AttendeeInvoicer.perform({:email => 'james.smith@theodi.org'}, {:id => 123456789}, {:amount => 0.66})
  #   # => nil
  #
  # Returns nil.
  def self.perform(user_details, event_details, payment_details)

  end

end