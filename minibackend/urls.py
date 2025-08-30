# urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
#from .views import UsuarioViewSet
from .views import *


router = DefaultRouter()
router.register(r"usuarios", UsuarioViewSet)
# Si descomento esto se crean las rutas para obtener todas las listas 
# y todos los articulos sin importar el usuario
router.register(r"listas", ListaViewSet)
router.register(r"articulos", ArticuloViewSet)

urlpatterns = [
    path("", include(router.urls)),
]
