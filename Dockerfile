FROM postgres:10
MAINTAINER Phuong Doan <pdoan@cuahsi.org>

ENV IRODS_VERSION=4.2.6

# set user/group IDs for irods account
RUN groupadd -r irods --gid=998 \
    && useradd -r -g irods -d /var/lib/irods --uid=998 irods \
    && mv /docker-entrypoint.sh /postgres-docker-entrypoint.sh

# install iRODS 
RUN echo "deb http://archive.debian.org/debian jessie-backports main" \
  > /etc/apt/sources.list.d/jessie-backports.list \
  && apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y \
  wget \
  gnupg2 \
  apt-transport-https \
  sudo \
  jq \
  libcurl4-openssl-dev \
  libxml2 \
  moreutils \
  && wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add - \
  && echo "deb [arch=amd64] https://packages.irods.org/apt/ xenial main" \
  > /etc/apt/sources.list.d/renci-irods.list \
  && apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y \
  irods-database-plugin-postgres=${IRODS_VERSION} \
  irods-icommands=${IRODS_VERSION}  \
  irods-runtime=${IRODS_VERSION}  \
  irods-server=${IRODS_VERSION}

# default iRODS and PostgreSQL environment variables
ENV IRODS_SERVICE_ACCOUNT_NAME=irods \
  IRODS_SERVICE_ACCOUNT_GROUP=irods \
  IRODS_SERVER_ROLE=1 \
  ODBC_DRIVER_FOR_POSTGRES=2 \
  IRODS_DATABASE_SERVER_HOSTNAME=localhost \
  IRODS_DATABASE_SERVER_PORT=5432 \
  IRODS_DATABASE_NAME=ICAT \
  IRODS_DATABASE_USER_NAME=irods \
  IRODS_DATABASE_PASSWORD=temppassword \
  IRODS_DATABASE_USER_PASSWORD_SALT=tempsalt \
  IRODS_ZONE_NAME=tempZone \
  IRODS_PORT=1247 \
  IRODS_PORT_RANGE_BEGIN=20000 \
  IRODS_PORT_RANGE_END=20199 \
  IRODS_CONTROL_PLANE_PORT=1248 \
  IRODS_SCHEMA_VALIDATION=file:///var/lib/irods/configuration_schemas \
  IRODS_SERVER_ADMINISTRATOR_USER_NAME=rods \
  IRODS_SERVER_ZONE_KEY=TEMPORARY_zone_key \
  IRODS_SERVER_NEGOTIATION_KEY=TEMPORARY_32byte_negotiation_key \
  IRODS_CONTROL_PLANE_KEY=TEMPORARY__32byte_ctrl_plane_key \
  IRODS_SERVER_ADMINISTRATOR_PASSWORD=rods \
  IRODS_VAULT_DIRECTORY=/var/lib/irods/iRODS/Vault \
  UID_POSTGRES=999 \
  GID_POSTGRES=999 \
  UID_IRODS=998 \
  GID_IRODS=998 \
  POSTGRES_USER=postgres \
  POSTGRES_PASSWORD=postgres

# create postgresql.tar.gz
RUN cd /var/lib/postgresql/data \
    && tar -czf /postgresql.tar.gz . \
    && cd /

# create irods.tar.gz
RUN cd /var/lib/irods \
    && tar -czf /irods.tar.gz . \
    && cd /

RUN useradd -m -p hsuserproxy -s /bin/bash hsuserproxy && \
    useradd -m -p rods -s /bin/bash rods && \
    mkdir -p /home/hsuserproxy/.irods

COPY ./docker-entrypoint.sh /irods-docker-entrypoint.sh
COPY ./irods_environment_user.json /tmp/irods_environment_user.json
COPY ./irods_environment_data.json /tmp/irods_environment_data.json
COPY ./irods_environment_hsuser.json /tmp/irods_environment_hsuser.json
COPY ./delete_user.sh /home/hsuserproxy/delete_user.sh
COPY ./create_user.sh /home/hsuserproxy/create_user.sh
COPY ./hydroshare-data.re /tmp
COPY ./hydroshare-user.re /tmp
COPY ./hydroshare-quota-microservices-ubuntu16-x86_64.deb /tmp

RUN chmod a+x /irods-docker-entrypoint.sh &&  apt install -y /tmp/hydroshare-quota-microservices-ubuntu16-x86_64.deb

EXPOSE $IRODS_PORT $IRODS_CONTROL_PLANE_PORT $IRODS_PORT_RANGE_BEGIN-$IRODS_PORT_RANGE_END

VOLUME /var/lib/irods /etc/irods /var/lib/postgresql/data /root /home/hsuserproxy

WORKDIR /var/lib/irods/

ENTRYPOINT ["/irods-docker-entrypoint.sh"]

