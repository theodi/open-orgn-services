require "active_support/inflector"
require "date"

require_relative '../hash_compact'
require_relative "../signup/product_helper"
require_relative "../capsulecrm/capsule_helper"
require_relative "../capsulecrm/send_signup_to_capsule"

class SignupProcessor
  @queue = :signup

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
    organization_details = {
      "name"           => organization["name"] || contact_person["name"],
      "contact_name"   => contact_person["name"],
      "company_number" => organization["company_number"],
      "email"          => billing["email"]
    }.compact

    membership = {
      "product_name"                   => purchase["offer_category"],
      "supporter_level"                => membership_type[:type],
      "id"                             => purchase["membership_id"].to_s,
      "join_date"                      => Date.today.to_s,
      "contact_email"                  => contact_person["email"],
      "twitter"                        => contact_person["twitter"],
      "size"                           => organization["size"],
      "sector"                         => organization["sector"],
      "origin"                         => organization["origin"],
      "coupon"                         => billing["coupon"],
      "newsletter"                     => organization["newsletter"],
      "share_with_third_parties"       => organization["share_with_third_parties"],
      "dob"                            => contact_person["dob"],
      "country"                        => contact_person["country"],
      "university_email"               => contact_person["university_email"],
      "university_address_country"     => contact_person["university_address_country"],
      "university_country"             => contact_person["university_country"],
      "university_name"                => contact_person["university_name"],
      "university_name_other"          => contact_person["university_name_other"],
      "university_course_name"         => contact_person["university_course_name"],
      "university_qualification"       => contact_person["university_qualification"],
      "university_qualification_other" => contact_person["university_qualification_other"],
      "university_course_start_date"   => contact_person["university_course_start_date"],
      "university_course_end_date"     => contact_person["university_course_end_date"]
    }.compact

    SendSignupToCapsule.perform(organization_details, membership)

    invoice_to = {
      "name" => organization["name"] || contact_person["name"],
      "contact_point" => {
        "name"      => billing["name"],
        "email"     => billing["email"],
        "telephone" => billing["telephone"],
      },
      "address" => {
        "street_address"   => billing["address"]["street_address"],
        "address_locality" => billing["address"]["address_locality"],
        "address_region"   => billing["address"]["address_region"],
        "address_country"  => billing["address"]["address_country"],
        "postal_code"      => billing["address"]["postal_code"]
      },
      "vat_id" => organization["vat_id"]
    }.compact

    invoice_description = invoice_description(
      purchase["membership_id"],
      membership_type[:description],
      organization["type"] || purchase["offer_category"],
      purchase["payment_method"],
      purchase["payment_method"] == "invoice" ? "annual" : purchase["payment_freq"]
    )

    invoice_details = {
      "payment_method" => purchase["payment_method"],
      "payment_ref"    => purchase["payment_ref"],
      "line_items" => [
        {
          "quantity"      => 1,
          "base_price"    => membership_type[:price],
          "discount_rate" => purchase["discount"],
          "description"   => invoice_description
        }
      ],
      "repeat"                   => "annual",
      "purchase_order_reference" => purchase["purchase_order_reference"],
      "sector"                   => organization["sector"]
    }.compact

    Resque.enqueue(Invoicer, invoice_to, invoice_details)
  end

  def membership_type
    if category == 'individual'
      {
        price: 90,
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

  def size
    organization['size']
  end

  def type
    organization['type']
  end

  def category
    purchase['offer_category']
  end

  def invoice_description(membership_id, description, type, method, frequency)
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

