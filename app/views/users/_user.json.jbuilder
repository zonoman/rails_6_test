json.extract! user, :id, :title, :content, :created_at, :updated_at
json.url user_url(user, format: :json)
