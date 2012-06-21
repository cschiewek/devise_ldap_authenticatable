FactoryGirl.define do
  factory :user do
    email "example.user@test.com"
    password "secret"
  end

  factory :admin, :class => User do
    email "example.admin@test.com"
    password "admin_secret"
  end

  factory :other, :class => User do
    email "other.user@test.com"
    password "other_secret"
  end
end
