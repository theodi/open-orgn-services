When /^I have asked to be contacted$/ do
  person  = {
    'name'           => @name,
    'affiliation'    => @company,
    'job_title'      => @job_title,
    'email'          => @email,
    'telephone'      => @phone,
  }
  product = {
    'name' => @membership_level
  }
  comment = {
    'text' => @comment_text
  }
  PartnerEnquiryProcessor.perform(person,product,comment)
end