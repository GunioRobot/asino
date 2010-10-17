Factory.define :account do |f|
  f.title 'Giro'
end

Factory.define :category do |f|
  f.name 'Kategorie'
end

Factory.define :user do |u|
  u.login 'user'
  u.password 'password'
  u.password_confirmation 'password'
end