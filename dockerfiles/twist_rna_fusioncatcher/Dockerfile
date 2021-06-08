# The build-stage image:
FROM continuumio/miniconda3 AS build

RUN apt update && apt install procps -y
# Install the package as normal:
COPY environment.yml /
RUN conda env create -f /environment.yml

# Install conda-pack:
RUN conda install -c conda-forge conda-pack

# Use conda-pack to create a standalone enviornment
# in /venv:
RUN conda-pack -n twist_rna_fusioncatcher -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /venv/bin/conda-unpack

# The runtime-stage image; we can use Debian as the
# base image since the Conda env also includes Python
# for us.
FROM debian:buster-slim AS runtime

################## METADATA ######################

LABEL fusioncatcher="1.30"
################## MAINTAINER ######################
MAINTAINER Jonas Almlöf <jonas.almlof@scilifelab.uu.se>


# Copy /venv from the previous stage:
# to /usr/local to make it possible
# running the softwares without activating
# any conda env


COPY --from=build /venv /usr/local
COPY --from=build /bin/ps /bin
COPY --from=build /lib/* /lib/
RUN mkdir /venv
RUN ln -s /usr/local/lib /venv/lib
RUN ln -s /usr/local/bin /venv/bin


SHELL ["/bin/bash", "-c"]
