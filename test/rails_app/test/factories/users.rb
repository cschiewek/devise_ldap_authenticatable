Factory.define :user do |f|
  f.email "example.user@test.com"
  f.password "secret"
  # f.encrypted_password "user_password"
  # f.password_salt  "12345"
end