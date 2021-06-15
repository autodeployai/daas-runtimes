# --------------------------------------------------------------
# Copyright (c) AutoDeployAI. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License").
# --------------------------------------------------------------
ARG base=18.04
FROM ubuntu:${base}

COPY requirements-*.txt /daas/

ENV LANG=C.UTF-8 \
  PATH=/opt/conda/bin:$PATH \
  JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Setup mirrors
ARG APT_MIRROR=
RUN [ -z "${APT_MIRROR}" ] || { sed -i "s@http://archive.ubuntu.com@http://${APT_MIRROR}@g" /etc/apt/sources.list &&\
  sed -i "s@http://security.ubuntu.com@http://${APT_MIRROR}@g" /etc/apt/sources.list &&\
  echo "APT mirror ${APT_MIRROR} used"; }
ARG PIP_MIRROR=
RUN [ -z "${PIP_MIRROR}" ] || { mkdir -p $HOME/.config/pip &&\
  echo "[global]\nindex-url = https://${PIP_MIRROR}" > $HOME/.config/pip/pip.conf &&\
  echo "PIP mirror ${PIP_MIRROR} used"; }

# Basic dependencies and jdk8
RUN apt-get update --fix-missing &&\
  apt-get install -y -q --no-install-recommends build-essential wget bzip2 ca-certificates curl libpq-dev default-libmysqlclient-dev cmake libkrb5-dev openjdk-8-jdk ca-certificates-java &&\
  apt-get -y autoclean &&\
  apt-get -y autoremove &&\
  rm -rf /var/lib/apt/lists/*

# Conda with the specified python version
ARG CONDA_VERSION=py37_4.8.2
ARG CONDA_MIRROR=repo.anaconda.com
RUN wget -q https://${CONDA_MIRROR}/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh &&\
  /bin/bash ~/miniconda.sh -b -p /opt/conda &&\
  rm ~/miniconda.sh &&\
  conda config --system --add channels conda-forge &&\
  conda clean -ya

# Spark and pypmml-spark
ARG APACHE_MIRROR=downloads.apache.org
ARG SPARK_VERSION=2.4.8
ARG HADOOP_VERSION=2.7
ENV SPARK_HOME=/usr/local/spark \
  PYTHONPATH=/usr/local/spark/python:$PYTHONPATH \
  PATH=/usr/local/spark/bin:$PATH
RUN cd /tmp &&\
  wget -q https://${APACHE_MIRROR}/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz &&\
  tar xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local &&\
  rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz &&\
  cd /usr/local &&\
  ln -s spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark-2.4 &&\
  ln -s spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark &&\
  pip install --no-deps pypmml-spark2 &&\
  link_pmml4s_jars_into_spark.py &&\
  rm -rf /root/.cache/pip

# ML/DL libraries and other ultilities
ENV PIP_DEFAULT_TIMEOUT=600
RUN cd /daas &&\
  pip install --upgrade pip setuptools &&\
  pip install -r requirements-ml.txt &&\
  pip install -r requirements-dl.txt &&\
  pip install -r requirements-image.txt &&\
  pip install -r requirements-database.txt &&\
  pip install -r requirements-nb.txt &&\
  pip install -r requirements-service.txt &&\
  rm -rf /root/.cache/pip

CMD [ "/bin/bash" ]
