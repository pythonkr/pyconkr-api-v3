from collections import defaultdict
from http import HTTPStatus
from os import getenv
from typing import Any

import ninja.router
from django.conf import settings
from django.db import DEFAULT_DB_ALIAS, DatabaseError, connections
from django.db.migrations.executor import MigrationExecutor
from django.http import HttpRequest, JsonResponse

router = ninja.router.Router(tags=["Health Check"])


def _check_databases() -> tuple[bool, dict[str, Any]]:
    results: dict[str, dict[str, Any]] = {}
    for alias in settings.DATABASES:
        results[alias] = {"success": True, "error": None}
        try:
            with connections[alias].cursor() as cursor:
                cursor.execute("SELECT 1")
        except DatabaseError as e:
            results[alias].update({"success": False, "error": str(e)})
    return all(results[key]["success"] for key in results), results


def _check_django_migrations() -> tuple[bool, defaultdict[str, list[str]]]:
    result: defaultdict[str, list[str]] = defaultdict(list)

    executor = MigrationExecutor(connections[DEFAULT_DB_ALIAS])
    migration_plan = executor.migration_plan(executor.loader.graph.leaf_nodes())
    for migration_info, _ in migration_plan:
        result[migration_info.app_label].append(migration_info.name)

    return bool(migration_plan), result


@router.get("/readyz/", url_name="readyz")
def readyz(request: HttpRequest) -> JsonResponse:
    is_dbs_ok, db_status = _check_databases()
    requires_migrations, migration_status = _check_django_migrations()
    response_data = (
        {
            "database": db_status,
            "migrations": migration_status,
            "git_sha": getenv("DEPLOYMENT_GIT_HASH", ""),
        }
        if settings.DEBUG
        else {}
    )
    return JsonResponse(
        data=response_data,
        status=HTTPStatus.OK if is_dbs_ok and requires_migrations else HTTPStatus.SERVICE_UNAVAILABLE,
    )


@router.get("/livez/", url_name="livez")
def livez(request: HttpRequest) -> JsonResponse:
    return JsonResponse({}, status=HTTPStatus.OK)
