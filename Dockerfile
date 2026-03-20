FROM mwaeckerlin/very-base
ENV CONTAINERNAME    "build"
USER root
RUN mkdir /app
RUN $ALLOW_BUILD /app
RUN $PKG_INSTALL git python3 g++ make gpg
WORKDIR /app