# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:8100'
    resource '/api/*',
      headers: :any,
      methods: %i(get post put)
  end
end
