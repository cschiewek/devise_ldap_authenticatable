Given /^the following logins:$/ do |logins|
  logins.hashes.each do |user|
    User.create(:email => user["email"], :password => user["password"])
  end
end

Given /^I check for SSL$/ do
  ::Devise.ldap_config = "#{Rails.root}/config/ssl_ldap.yml" if ENV["LDAP_SSL"]
end

When /^I delete the (\d+)(?:st|nd|rd|th) login$/ do |pos|
  visit logins_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following logins:$/ do |expected_logins_table|
  expected_logins_table.diff!(tableish('table tr', 'td,th'))
end

