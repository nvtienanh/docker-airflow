FROM python:3.7.6-alpine3.9
LABEL maintainer="nvtienanh"

ARG BUILD_DATE
ARG VCS_REF
ARG AIRFLOW_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.name="Apache Airflow" \
        org.label-schema.description="An Apache Airflow docker image based on Alpine Linux" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url="https://github.com/nvtienanh/docker-airflow" \
        org.label-schema.vendor="nvtienanh" \
        org.label-schema.version=$AIRFLOW_VERSION \
        org.label-schema.schema-version="1.0"

# Replace the apk repositories for a better performance
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories

# Update the package list
RUN apk update

# Set timezone
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime \
    && apk del tzdata

# Airflow
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS="datadog,dask"
ARG PYTHON_DEPS="flask_oauthlib>=0.9"
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN apk add --no-cache \
    bash \
    g++ \
    libressl-dev \
    musl-dev \
    libffi-dev \
    mariadb-dev \
    postgresql-dev \
    git \
    make \
    curl \
    rsync \
    linux-headers \
    && pip install psycopg2 \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip install 'redis==3.2' \
    && adduser -D -u 1000 airflow \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && rm -rf /var/cache/apk/*

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_USER_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]
