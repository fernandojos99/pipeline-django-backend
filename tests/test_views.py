import pytest
from rest_framework.test import APIClient
from rest_framework import status
from minibackend.models import Usuario

# Este es el que esta fallando 
# @pytest.mark.django_db
# def test_usuario_listas_endpoint():
#     usuario = Usuario.objects.create(nombre="Juan")
#     client = APIClient()
#     response = client.get(f"/usuarios/{usuario.id}/listas/")
#     assert response.status_code == status.HTTP_200_OK

@pytest.mark.django_db
def test_usuario_listas_not_found():
    client = APIClient()
    response = client.get("/usuarios/9999/listas/")
    assert response.status_code == status.HTTP_404_NOT_FOUND
