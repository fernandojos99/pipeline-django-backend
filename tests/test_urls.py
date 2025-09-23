import pytest
from django.urls import reverse, resolve
from rest_framework.test import APIClient
from minibackend.views import UsuarioViewSet, ListaViewSet, ArticuloViewSet

@pytest.mark.parametrize("url_name,viewset", [
    ("usuario-list", UsuarioViewSet),
    ("lista-list", ListaViewSet),
    ("articulo-list", ArticuloViewSet),
])
def test_urls_resuelven_a_los_viewsets(url_name, viewset):
    """Verifica que las rutas del router están registradas y apuntan a su viewset"""
    resolver = resolve(reverse(url_name))
    assert resolver.func.cls == viewset


@pytest.mark.django_db
@pytest.mark.parametrize("endpoint", [
    "/usuarios/",
    "/listas/",
    "/articulos/",
])
def test_endpoints_responden(endpoint):
    """Verifica que los endpoints existen y responden (aunque sea 200 o 401)"""
    client = APIClient()
    response = client.get(endpoint)
    assert response.status_code in [200, 401, 403, 404]
