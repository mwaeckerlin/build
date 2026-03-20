FROM mwaeckerlin/very-base
ARG PACKAGES="git python3 g++ make gpg"
ENV CONTAINERNAME    "build"
USER root
RUN mkdir /app
RUN $ALLOW_BUILD /app
RUN $PKG_INSTALL $PACKAGES
WORKDIR /app