# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


puts "Creating admin user..."
User.create(email: "admin@example.com", password: "password", first_name: "Admin", last_name: "Admin", role: 0)
puts "Admin user created"

puts "Creating teacher user..."
User.create(email: "teacher@example.com", password: "password", first_name: "Teacher", last_name: "Teacher", role: 1)
puts "Teacher user created"

puts "Creating student user..."
User.create(email: "student@example.com", password: "password", first_name: "Student", last_name: "Student", role: 2)
puts "Student user created"