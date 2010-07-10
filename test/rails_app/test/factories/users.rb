Factory.define :user do |f|
  f.email "example.user@test.com"
  f.password "secret"
end

Factory.define :admin, :class => "user" do |f|
  f.email "example.admin@test.com"
  f.password "admin_secret"
end