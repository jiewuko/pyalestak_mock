FROM python:3.9-slim

ENV USER=bitnet \
    USER_ID=1000 \
    APP_PORT=8080 \
    APP_HOST=0.0.0.0 \
    LOG_LEVEL="INFO" \
    USE_SWAGGER="False" \
    DEBUG='False' \
    PROJECT_PATH="/var/app" \
    LANG="C.UTF-8" \
    LANGUAGE="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    SECRET_KEY='wo=zt==6h-t86jbdy_8flzv1*f=$nb20h-bd*p8=3a-)$yq8uo' \
    BUILD_PACKAGES="build-essential gcc linux-headers-amd64 libffi-dev libgeos-c1v5 libpq-dev libssl-dev" \
    FETCH_PACKAGES="wget gnupg2" \
    PACKAGES="postgresql-client-11 git redis-tools netcat curl" \
    DJANGO_SETTINGS_MODULE=app.settings

RUN echo "Installing and updatig system packages..." && \
    apt update && \
    apt install -y ${FETCH_PACKAGES} && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends ${BUILD_PACKAGES} ${PACKAGES} && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir -U pipenv && \
    useradd -m -o -u ${USER_ID} -d ${PROJECT_PATH} ${USER}

WORKDIR ${PROJECT_PATH}
EXPOSE ${PORT}
CMD ["/usr/local/bin/gunicorn", "-c", "gunicorn.py", "app.wsgi:application"]

ADD Pipfile* ${PROJECT_PATH}/
ARG WITH_DEV_PACKAGES=no

RUN cd ${PROJECT_PATH} && \
    [ "${WITH_DEV_PACKAGES}x" = "yesx" ] && dev_packages_param="-d" || dev_packages_param="" && \
    echo "Installing python packages`[ "${WITH_DEV_PACKAGES}x" = "yesx" ] && echo " in dev mode"`..." && \
    pipenv install ${dev_packages_param} --deploy --system && \
    apt purge -y ${BUILD_PACKAGES} && \
    apt purge -y ${FETCH_PACKAGES} && \
    apt autoremove -y

ADD . ${PROJECT_PATH}
ARG BUILD_STATIC=no

RUN echo "Invoking Django commands..." && \
    cd ${PROJECT_PATH} && \
    [ "${BUILD_STATIC}x" = "yesx" ] && USE_SWAGGER=True PYTHONPATH='.' python manage.py collectstatic --no-input || true && \
    [ "${WITH_DEV_PACKAGES}x" != "yesx" ] && rm -rf tests || true && \
    chown -R ${USER}:${USER} ${PROJECT_PATH} && \
    find . -iname "*.pyc" -delete

VOLUME ${PROJECT_PATH}/static
USER ${USER_ID}
EXPOSE ${APP_PORT}
