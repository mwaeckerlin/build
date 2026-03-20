FROM mwaeckerlin/very-base
ARG PACKAGES="git python3 g++ make gpg npm yarn nodejs linux-headers"
ENV CONTAINERNAME "build"
ENV NODE_ENV      "development"
ENV PATH          "node_modules/.bin:/app/node_modules/.bin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin"
USER root
RUN mkdir /app
RUN $ALLOW_BUILD /app
RUN $PKG_INSTALL $PACKAGES
USER ${BUILD_USER}
WORKDIR /app