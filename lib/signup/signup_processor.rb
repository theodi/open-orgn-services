require "active_support/inflector"
require "date"

require_relative '../hash_compact'
require_relative "../signup/product_helper"
require_relative "../capsulecrm/capsule_helper"
require_relative "../capsulecrm/send_signup_to_capsule"

class SignupProcessor
  @queue = :signup

  # Public: Process new signups from the member site
  #
  # expects input of the following form...
  #
  # organization      - a hash containing the details of the member organisation
  #                   'name'
  #                   'vat_id'
  #                   'company_number'
  #                   'size'
  #                   'type'
  #                   'sector'
  #                   'origin'
  #
  # contact_person    - a hash containing details of the main contact for the member organisation
  #                    'name'
  #                    'email'
  #                    'telephone'
  #
  # billing           - a hash containing the details of the billing contact for the member organisation
  #                   'name'
  #                   'email'
  #                   'telephone'
  #                   'address' => {
  #                      'street_address' => ...,
  #                      'address_locality',
  #                      'address_region',
  #                      'address_country',
  #                      'postal_code'
  #                    }
  #
  # purchase          - a hash containing information about the purchase
  #                   'payment_method'
  #                   'payment_freq'
  #                   'payment_ref'
  #                   'offer_category'
  #                   'purchase_order_reference'
  #                   'membership_id'
  #                   'discount'


  # Returns nil. Queues invoicing and CRM task creation jobs.

  def self.perform(organization, contact_person, billing, purchase)
    self.new(organization, contact_person, billing, purchase).perform
  end

  attr_reader :organization, :contact_person, :billing, :purchase

  def initialize(organization, contact_person, billing, purchase)
    @organization   = organization
    @contact_person = contact_person
    @billing        = billing
    @purchase       = purchase
  end

  def perform

    # Save details in capsule
    membership_type = membership_type(organization['size'], organization['type'], purchase['offer_category'])

    organization_details = {
      'name' => organization['name'] || contact_person['name'],
      'company_number' => organization['company_number'],
      'email' => billing['email']
    }.compact
    membership = {
      'product_name'    => purchase['offer_category'],
      'supporter_level' => membership_type[:type],
      'id'              => purchase['membership_id'].to_s,
      'join_date'       => Date.today.to_s,
      'contact_email'   => contact_person['email'],
      'size'            => organization['size'],
      'sector'          => organization['sector'],
      'origin'          => organization['origin']
    }.compact

    SendSignupToCapsule.perform(organization_details, membership)

    invoice_to = {
      'name' => organization['name'] || contact_person['name'],
      'contact_point' => {
        'name' => billing['name'],
        'email' => billing['email'],
        'telephone' => billing['telephone'],
      },
      'address' => {
        'street_address' => billing['address']['street_address'],
        'address_locality' => billing['address']['address_locality'],
        'address_region' => billing['address']['address_region'],
        'address_country' => billing['address']['address_country'],
        'postal_code' => billing['address']['postal_code']
      },
      'vat_id' => organization['vat_id']
    }.compact

    invoice_description = description(purchase['membership_id'],
                                 membership_type[:description],
                                 organization['type'] || purchase['offer_category'],
                                 purchase['payment_method'],
                                 purchase['payment_method'] == 'invoice' ? 'annual' : purchase['payment_freq']
                                )

    invoice_details = {
      'payment_method' => purchase['payment_method'],
      'payment_ref' => purchase['payment_ref'],
      'line_items' => [{
          'quantity'      => 1,
          'base_price'    => membership_type[:price],
          'discount_rate' => purchase['discount'],
          'description'   => invoice_description
      }],
      'repeat' => 'annual',
      'purchase_order_reference' => purchase['purchase_order_reference'],
      'sector' => organization['sector']
    }.compact
    Resque.enqueue(Invoicer, invoice_to, invoice_details)
  end

  def membership_type(size, type, category)
    if category == 'individual'
      {
        price: 108,
        description: 'Individual supporter',
        type: 'Individual'
      }
    elsif category == 'student'
      {
        price: 0,
        description: 'Individual student supporter',
        type: 'Student'
      }
    elsif %w(<10 10-50 51-250).include?(size) || type == 'non_commercial'
      {
        price: (60 * 12),
        description: 'Supporter',
        type: 'Supporter'
      }
    else
      {
        price: 2200,
        description: 'Corporate Supporter',
        type: 'Corporate supporter'
      }
    end
  end

  def description(membership_id, description, type, method, frequency)
    "ODI #{description} (#{membership_id}) [#{type.titleize}] (#{frequency} #{format_payment_method(method)} payment)"
  end

  def format_payment_method(method)
    case method
    when 'credit_card'
      'card'
    when 'direct_debit'
      'dd'
    else
      method
    end
  end
end

