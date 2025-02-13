json.extract! person, :id, :lastname, :firstname, :email, :phone_number, :type, :created_at, :updated_at
json.url person_url(person, format: :json)
