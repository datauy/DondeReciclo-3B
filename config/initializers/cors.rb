# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
   allow do
      origins 'https://dondereciclo.uy', 'https://dondereciclo.com.uy', 'https://www.dondereciclo.uy', 'https://www.dondereciclo.com.uy', 'https://dondereciclo.co', 'https://www.dondereciclo.co'
      resource '/api/*',
        headers: :any,
        methods: %i(get post put)
    end
    allow do
      origins 'https://dr.data.org.uy', 'https://dr.stage.data.org.uy', 'http://localhost', 'http://localhost:8100', 'localhost'
      resource '/api/*',
        headers: ['Access-Control-Allow-Headers','Content-Type','X-Amz-Date','Authorization','X-Api-Key','Origin','Accept','Access-Control-Allow-Headers','Access-Control-Allow-Methods','Access-Control-Allow-Origin'],
        methods: %i(get post put)
    end
    allow do
      origins 'https://dr.data.org.uy', 'https://dr.stage.data.org.uy', 'http://localhost', 'http://localhost:8100', 'localhost', 'https://dondereciclo.uy', 'https://dondereciclo.com.uy', 'https://www.dondereciclo.uy', 'https://www.dondereciclo.com.uy', 'https://dondereciclo.co', 'https://www.dondereciclo.co'
      resource '/users',
        headers: ['Access-Control-Allow-Headers','Content-Type','X-Amz-Date','Authorization','X-Api-Key','Origin','Accept','Access-Control-Allow-Headers','Access-Control-Allow-Methods','Access-Control-Allow-Origin'],
        methods: [:post]
    end
    allow do
      origins 'https://dr.data.org.uy', 'https://dr.stage.data.org.uy', 'http://localhost', 'http://localhost:8100', 'localhost', 'https://dondereciclo.uy', 'https://dondereciclo.com.uy', 'https://www.dondereciclo.uy', 'https://www.dondereciclo.com.uy', 'https://dondereciclo.co', 'https://www.dondereciclo.co'
      resource '/oauth/token',
        headers: ['Access-Control-Allow-Headers','Content-Type','X-Amz-Date','Authorization','X-Api-Key','Origin','Accept','Access-Control-Allow-Headers','Access-Control-Allow-Methods','Access-Control-Allow-Origin'],
        methods: [:post]
    end
    allow do
      origins 'https://dr.data.org.uy', 'https://dr.stage.data.org.uy', 'http://localhost', 'http://localhost:8100', 'localhost', 'https://dondereciclo.uy', 'https://dondereciclo.com.uy', 'https://www.dondereciclo.uy', 'https://www.dondereciclo.com.uy', 'https://dondereciclo.co', 'https://www.dondereciclo.co'
      resource '/password/*',
        headers: ['Access-Control-Allow-Headers','Content-Type','X-Amz-Date','Authorization','X-Api-Key','Origin','Accept','Access-Control-Allow-Headers','Access-Control-Allow-Methods','Access-Control-Allow-Origin'],
        methods: [:post]
    end
end
