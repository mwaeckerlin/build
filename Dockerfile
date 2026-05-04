FROM mwaeckerlin/very-base
ARG PACKAGES="autoconf automake bash build-base bzip2 ca-certificates curl g++ gcompat git git gpg gpg-agent gpgv libffi-dev libtool linux-headers make nodejs npm openssl-dev php py3-pip python3 readline-dev ruby ruby-dev upx yarn zlib-dev"
ENV CONTAINERNAME "build"
ENV NODE_ENV      "development"
ENV PATH          "node_modules/.bin:/app/node_modules/.bin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin"
USER root
RUN mkdir /app
RUN $ALLOW_BUILD /app /tmp
RUN $PKG_INSTALL $PACKAGES
USER ${BUILD_USER}
WORKDIR /app