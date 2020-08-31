#Donde Reciclo 3.0 Backend 0.4
Repositorio del backend de Dónde Reciclo en su última edición con Rails con objetos editables para el manejo de datos por parte de los programas y nuevas interacciones.
## Versión 0.4.1
La versión incluye la funcionalidad completa para la base de Donde Reciclo 3.0.

* Ruby version 2.6.3  

* Rails version 6.0.2

* System dependencies
  - NodeJS, rails dependencies  
  - bundle/bundler

```bash
git clone https://github.com/datauy/DondeReciclo-3B.git
cd DondeReciclo-3B
gem install bundler:2.0.2
bundle install
#Create database
cp config/database.yml.example config/database.yml
#Modify db file
rails credentials:edit
rails db:migrate
yarn install [npm install -g yarn]
rails db:seed
rails s
```

##Services
get 'api/materials'
get 'api/container_types'
get 'api/container/:id'
get 'api/containers'
get 'api/containers_bbox'
get 'api/containers_bbox4materials'
get 'api/containers_nearby'
get 'api/search'
get 'api/search_predefined'
get 'api/containers4materials'
get 'api/programs'
get 'api/news'
get "api/new/:id"
post 'api/contact'
Funciones de usuario

