# Esta rama solo es de pruebas para pipeline CI/CD  
## no tomar en cuenta 

Le coloque 6 pruebas unitarias con pytest  


# Django-rest
Es un minibackend para entender el funcionamiento de despliegues

## Para ejecutarlo 

### 1. Crear un entorno virtual y activarlo
```bash
python3 -m venv mi_entorno  
```

### 2. Activar el entorno virtual
```bash
source mi_entorno/bin/activate 
```

### 3. Instalar los requerimientos 
```bash
pip install -r requirements.txt
```

**Nota:** Los requirements incluyen `django-cors-headers` que es necesario para permitir conexiones desde el frontend React.

### 4. Hacer migraciones necesarias 
```bash
python manage.py makemigrations
python manage.py migrate
```

### 5. Ejecutar el servidor
Por default sale en el puerto 8000 pero si lo tienes ocupado ver en la consola cual te asignó:
```bash
python manage.py runserver
```

El servidor estará disponible en: **http://localhost:8000**

## Configuración CORS

El proyecto incluye configuración CORS para permitir peticiones desde:
- `http://localhost:3000` (Frontend React en desarrollo)
- `http://127.0.0.1:3000`

Si necesitas agregar otros orígenes, modifica `CORS_ALLOWED_ORIGINS` en `settings.py`.

## Endpoints disponibles

- `GET/POST /api/usuarios/` - Listar/crear usuarios
- `GET/PUT/PATCH/DELETE /api/usuarios/{id}/` - Operaciones con usuario específico

## Hacer request 

Para que sea más fácil pueden importar el archivo `CRUDDjango-Rest.postman_collection.json` en Postman para que les salgan ejemplos de peticiones.


## docker-compose 
Utilizar la siguiente instruccion para compilar y ejecutar todo el proyecto tanto frontend como backend 

```
docker-compose up

```
Para detenerlo 
```
docker-compose down

```
