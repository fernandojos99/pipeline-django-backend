from django.shortcuts import render

# views.py
from rest_framework import viewsets
from minibackend.models import Usuario, Lista, Articulo
from .serializers import *

# views.py
from rest_framework.decorators import action
from rest_framework.response import Response

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer

    # Esto solo regresa las listas correspondientes al usuario actual
    @action(detail=True, methods=["get"])
    def listas(self, request, pk=None):
        usuario = self.get_object()
        listas = usuario.listas.all()  # usamos el related_name definido en el modelo
        serializer = ListaSerializer(listas, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=["get"])
    def articulos(self, request, pk=None):
        usuario = self.get_object()
        articulos = Articulo.objects.filter(listas__usuario=usuario).distinct()
        serializer = ArticuloSerializer(articulos, many=True)
        return Response(serializer.data)


# Si no las comento me saldrian todas las listas y todos los articulos independiente 
# Si especifico  el usuario 
#
# ## Esto regresa todas las listas existentes
class ListaViewSet(viewsets.ModelViewSet):
    queryset = Lista.objects.all()
    serializer_class = ListaSerializer

class ArticuloViewSet(viewsets.ModelViewSet):
    queryset = Articulo.objects.all()
    serializer_class = ArticuloSerializer
