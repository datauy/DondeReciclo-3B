# Documentación de la API

## Servicios

```text
GET  /api/location4Polygon
GET  /api/country4Point
GET  /api/subprograms4location
GET  /api/subprogram4location
GET  /api/zone4point
GET  /api/materials
GET  /api/wastes
GET  /api/container_types
GET  /api/container/:id
GET  /api/containers
GET  /api/containers_bbox
GET  /api/containers_bbox4materials
GET  /api/cluster_details
GET  /api/containers_nearby
GET  /api/containers4materials
GET  /api/search
GET  /api/search_predefined
GET  /api/programs
GET  /api/programs_sum
GET  /api/news
GET  /api/new/:id
POST /api/contact
GET  /api/user
POST /api/user/update
POST /api/report
POST /api/collect
POST /password/forgot
POST /password/reset
```

## Búsqueda de contenedores por área

`GET /api/containers_bbox` y `GET /api/containers_bbox4materials` reciben
`sw` y `ne` como `latitud,longitud` (esquina sudoeste y noreste). Los límites
son inclusivos; se admiten áreas que cruzan el antimeridiano. Solo se devuelven
contenedores públicos y no ocultos. La versión se selecciona con `version`
(por defecto v1; `version=2` selecciona v2).

En `containers_bbox4materials`, `materials` o `wastes` filtra por una lista
de IDs separados por comas. Si se envían ambos, tiene prioridad `materials`.
En v2, `dimensions` tiene prioridad sobre ambos y usa el filtro existente de
materiales y residuos. Sin filtros se comporta como `containers_bbox`.

La agrupación está disponible solo en v2 (`version=2`). En v1 el parámetro
`clustered` se ignora y la respuesta sigue siendo la habitual. En v2, por
defecto o con `clustered=false`, la respuesta mantiene el formato y los
límites anteriores. Con `clustered=true` se aplica primero el filtro y se
devuelve un arreglo plano de contenedores individuales y agrupaciones:

```json
[
  { "cluster": true, "latitude": -34.9, "longitude": -56.2, "count": 2, "ids": [123, 456] }
]
```

La agrupación divide el área solicitada en una cuadrícula de 40 × 40 celdas
de igual tamaño angular; los puntos en una misma celda forman una agrupación.
El límite noreste pertenece a la última celda y una dimensión de ancho cero
usa una sola celda. La ubicación representativa es la del miembro con menor
ID. Cada contenedor aparece una sola vez; los IDs son únicos, positivos y no
se truncan. Un contenedor con ID no positivo queda como resultado individual.
Los contenedores individuales conservan el formato habitual de la versión
solicitada. El cliente puede obtener los miembros de una agrupación mediante
`GET /api/cluster_details` (ver más abajo).

Para agrupaciones, `sw` y `ne` deben contener coordenadas finitas válidas
(`-90..90` de latitud, `-180..180` de longitud, con latitud sudoeste no
mayor a la noreste), y los filtros deben contener IDs enteros positivos.
En v2, `clustered` solo acepta `true` o `false`. Parámetros inválidos devuelven
HTTP 400 con un objeto `error`. El cliente actual solicita `clustered=true`
desde zoom 14; la cuadrícula usa el área y no requiere enviar el zoom.

## Detalle de una agrupación

`GET /api/cluster_details?version=2&container_ids=123,456` (solo v2) devuelve los
contenedores indicados para mostrarlos en el modal de una agrupación.
`ids` es obligatorio: lista de IDs enteros positivos separados por comas
(se eliminan duplicados), hasta 500. Solo se devuelven contenedores públicos
y no ocultos, ordenados por ID. Cada elemento tiene el formato de los
contenedores individuales y agrega el subprograma:

```json
[
  {
    "id": 123,
    "latitude": -34.9,
    "longitude": -56.2,
    "main_material": 3,
    "custom_icon": "",
    "sub_program_id": 7,
    "sub_program_name": "Programa de papel"
  }
]
```

Un `ids` ausente, mal formado o con más de 500 elementos devuelve HTTP 400
con un objeto `error`.
