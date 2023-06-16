ARG UBUNTU_VERSION="20.04"
ARG AIRFLOW_HOME="/opt/airflow"

# Base image
FROM ubuntu:${UBUNTU_VERSION}

ENV AIRFLOW_USER_HOME_DIR="/home/airflow"

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.8 as the default python version
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# Install additional dependencies for Airflow providers
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
    gcc \
    g++ \
    apt-transport-https apt-utils ca-certificates\
    curl dumb-init freetds-bin gosu libkrb5-dev krb5-user \
    ldap-utils libffi7 libldap-2.4-2 libsasl2-dev libsasl2-2 libsasl2-modules libssl1.1 \
    lsb-release netcat openssh-client python3-selinux rsync sasl2-bin sqlite3 unixodbc \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt

# Install additional dependencies
RUN pip install setuptools wheel \
    && pip install -r /tmp/requirements.txt --no-cache-dir

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install Apache Airflow
RUN pip install 'apache-airflow==2.5.3' --constraint 'https://raw.githubusercontent.com/apache/airflow/constraints-2.5.3/constraints-3.8.txt'

# Create the airflow user
RUN useradd -ms /bin/bash airflow

# Set the entrypoint
COPY entrypoint.sh /entrypoint

# Grant access entrypoint 
RUN chmod +x /entrypoint

# Set the airflow user
USER airflow

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint"]
