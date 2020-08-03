# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
   allow do
      origins 'https://dondereciclo.uy', 'https://dondereciclo.com.uy', 'https://www.dondereciclo.uy', 'https://www.dondereciclo.com.uy'
      resource '/api/*',
        headers: :any,
        methods: %i(get post put)
    end
    allow do
      origins 'https://dr.dev.data.org.uy', 'http://localhost', 'http://localhost:8100', 'localhost'
      resource '/api/*',
        headers: ['Access-Control-Allow-Headers','Content-Type','X-Amz-Date','Authorization','X-Api-Key','Origin','Accept','Access-Control-Allow-Headers','Access-Control-Allow-Methods','Access-Control-Allow-Origin'],
        methods: %i(get post put)
    end
    allow do
      origins 'https://dr.dev.data.org.uy', 'http://localhost', 'http://localhost:8100', 'localhost', 'https://dondereciclo.uy', 'https://dondereciclo.com.uy', 'https://www.dondereciclo.uy', 'https://www.dondereciclo.com.uy'
      resource '/users',
        headers: ['Access-Control-Allow-Headers','Content-Type','X-Amz-Date','Authorization','X-Api-Key','Origin','Accept','Access-Control-Allow-Headers','Access-Control-Allow-Methods','Access-Control-Allow-Origin'],
        methods: [:post]
    end
    allow do
      origins 'https://dr.dev.data.org.uy', 'http://localhost', 'http://localhost:8100', 'localhost', 'https://dondereciclo.uy', 'https://dondereciclo.com.uy', 'https://www.dondereciclo.uy', 'https://www.dondereciclo.com.uy'
      resource '/oauth/token',
        headers: ['Access-Control-Allow-Headers','Content-Type','X-Amz-Date','Authorization','X-Api-Key','Origin','Accept','Access-Control-Allow-Headers','Access-Control-Allow-Methods','Access-Control-Allow-Origin'],
        methods: [:post]
    end
end
