
# Django REST

This is a **mini backend** created to understand how **deployment workflows** work.

---

## How to run it

### 1. Create and activate a virtual environment
```bash
python3 -m venv mi_entorno
```
### 2. Activate the virtual environment
```bash
source mi_entorno/bin/activate 
```

### 3. Install requirements 
```
pip install -r requirements.txt
```
Note: The requirements include django-cors-headers, which is required to allow connections from the React frontend.

### 4. Run the requiered migrations
```
python manage.py makemigrations
python manage.py migrate
```

### 5. Start the server
By default, the server runs on port 8000, but if it is already in use, check the console output to see which port was assigned:
```
python manage.py runserver
```

The server will be available at: http://localhost:8000

### CORS Configuration

This project includes CORS configuration to allow requests from:
```
http://localhost:3000 (React frontend in development)

http://127.0.0.1:3000
```
If you need to add other origins, modify `CORS_ALLOWED_ORIGINS` in settings.py.

## Available Endpoints

- `GET/POST /api/usuarios/` - Listar/crear usuarios
- `GET/PUT/PATCH/DELETE /api/usuarios/{id}/` - Opetations on a specefic user

## Making Requests

To make testing easier, you can import the file
`CRUDDjango-Rest.postman_collection.json`
into Postman to see example requests.


## docker-compose (disabled option)
Use the following command to build and run the entire project (both frontend and backend): 

```
docker-compose up

```
to stop it 
```
docker-compose down

```

---

# Pipeline

Inside the .github/workflows folder, there is a pipeline that performs the following steps:

* Build the application
* Authenticate with AWS
* Push the image to AWS
* Connect to an EC2 instance and pull the image on that instance
* Start the backend service















