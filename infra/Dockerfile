ARG PYTHON_VERSION=3.11
FROM public.ecr.aws/lambda/python:${PYTHON_VERSION}
WORKDIR ${LAMBDA_TASK_ROOT}
SHELL [ "/bin/bash", "-euxvc"]

ENV PATH="${PATH}:/root/.local/bin:" \
    TZ=Asia/Seoul \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONUNBUFFERED=1

# Setup timezone, user, and install dependencies, and clean up
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy only the dependencies files to cache them in docker layer
COPY --chown=nobody:nobody pyproject.toml poetry.lock ${LAMBDA_TASK_ROOT}

RUN curl -sSL https://install.python-poetry.org | python3 - \
    && poetry config virtualenvs.create false  \
    && poetry config installer.max-workers 10 \
    && poetry install --only main --no-interaction --no-ansi --no-root

RUN ZAPPA_HANDLER_PATH=$(python -c 'import zappa.handler; print(zappa.handler.__file__)') \
    && echo $ZAPPA_HANDLER_PATH \
    && cp $ZAPPA_HANDLER_PATH ${LAMBDA_TASK_ROOT}

ARG GIT_HASH
ENV DEPLOYMENT_GIT_HASH=$GIT_HASH

# Make docker to always copy app directory so that source code can be refreshed.
ARG IMAGE_BUILD_DATETIME=unknown
ENV DEPLOYMENT_IMAGE_BUILD_DATETIME=$IMAGE_BUILD_DATETIME

# Copy main app and zappa settings
COPY --chown=nobody:nobody pyconkr ${LAMBDA_TASK_ROOT}/pyconkr
COPY --chown=nobody:nobody zappa_settings.py ${LAMBDA_TASK_ROOT}

# The reason for using nobody user is to avoid running the app as root, which can be a security risk.
USER nobody
CMD ["handler.lambda_handler"]
