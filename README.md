#Donde Reciclo 3 Backend 2.0
Repositorio del backend de Dónde Reciclo en su última edición con Rails con objetos editables para el manejo de datos por parte de los programas y nuevas interacciones.
## Versión 2.2.6
Se agregan datos del Plan Vale para Rocha
## Versión 2.2.3
Se pasan reportes a público. Se agregan localidades de Canelones y se corrige admin de Localidades
### Versión 2.2.0
Se agregan funciones de materiales para contenedores, de forma de soportar tales búsquedas
### Versión 2.1.0
Esta versión agrega funcionalidades de dimensiones de economía circular y versionador para la API 
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

## Documentación de la API

Consulta la [documentación de la API](docs/api.md) para ver los servicios y
la búsqueda de contenedores por área.
