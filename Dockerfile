FROM mjstealey/irods-provider-postgres:4.2.4

RUN useradd -m -p hsuserproxy -s /bin/bash hsuserproxy
RUN useradd -m -p rods -s /bin/bash rods
RUN mkdir -p /home/hsuserproxy/.irods
COPY ./irods_environment.json /root/.irods/irods_environment.json
COPY ./delete_user.sh /home/hsuserproxy/delete_user.sh
COPY ./create_user.sh /home/hsuserproxy/create_user.sh
COPY ./hydroshare-data.re /tmp
COPY ./hydroshare-user.re /tmp
COPY ./hydroshare-quota-microservices-ubuntu16-x86_64.deb /tmp

RUN apt update || echo 0
RUN apt install /tmp/hydroshare-quota-microservices-ubuntu16-x86_64.deb

RUN chmod -R 777 /home

VOLUME /var/lib/irods /etc/irods /var/lib/postgresql/data
