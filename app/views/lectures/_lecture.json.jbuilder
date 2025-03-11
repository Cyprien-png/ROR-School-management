json.extract! lecture, :id, :start_time, :end_time, :week_day, :created_at, :updated_at
json.url lecture_url(lecture, format: :json)
