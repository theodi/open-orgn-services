require 'resque'

class AttendeeInvoicer
  @queue = :invoicing

  def self.perform(email, amount)
    puts "invoice #{email} #{amount}"
  end
end