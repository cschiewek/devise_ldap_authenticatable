Factory.define :user do |f|
  f.email "example.user@test.com"
  f.password "secret"
end

Factory.define :admin, :class => "user" do |f|
  f.email "example.admin@test.com"
  f.password "admin_secret"
end

Factory.define :other, :class => "user" do |f|
  f.email "other.user@test.com"
  f.password "other_secret"
end