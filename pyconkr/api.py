import ninja.main
from django.conf import settings

from pyconkr.health_check import router as health_check_route

api = ninja.main.NinjaAPI(
    title="PyCon Korea API Server V3",
    version="v1",
    urls_namespace="api",
    docs_url="/docs" if settings.DEBUG else None,
)

api.add_router(prefix="", router=health_check_route)
