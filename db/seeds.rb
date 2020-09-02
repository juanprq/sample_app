User.create!(
  name: 'Example user',
  email: 'example@railstutorial.com',
  password: 'password',
  password_confirmation: 'password',
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

99.times do |n|
  User.create!(
    name: Faker::Name.name,
    email: "example-#{n}@railstutorial.com",
    password: 'password',
    password_confirmation: 'password',
    activated: true,
    activated_at: Time.zone.now
  )
end
