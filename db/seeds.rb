# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a Teacher
Teacher.create(
  lastname: "Doe",
  firstname: "John",
  email: "john.doe@example.com",
  phone_number: "1234567890",
  iban: "GB29NWBK60161331926819",
  password: "password",
  password_confirmation: "password"
)

# Create a Student
Student.create(
  lastname: "Smith",
  firstname: "Jane",
  email: "jane.smith@example.com",
  phone_number: "0987654321",
  status: 0,
  password: "password",
  password_confirmation: "password"
)

# Create a Dean
Dean.create(
  lastname: "Johnson",
  firstname: "Emily",
  email: "emily.johnson@example.com",
  phone_number: "5551234567",
  password: "password",
  password_confirmation: "password"
)
