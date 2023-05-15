# frozen_string_literal: true

# seed for admin user
admin_user1 = User.create(
  email: 'admin001@letterheals.com',
  phone_number: '+639456421990',
  password: 'passworD#12345',
  password_confirmation: 'passworD#12345'
)

admin_user2 = User.create(
  email: 'admin002@letterheals.com',
  phone_number: '+639456421991',
  password: 'passworD#12345',
  password_confirmation: 'passworD#12345'
)

# update admin user password digest

admin_user1.update(verified: true)
admin_user2.update(verified: true)
