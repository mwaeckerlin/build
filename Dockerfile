FROM mwaeckerlin/very-base
ARG PACKAGES="g++ git gpg gpg-agent gpgv linux-headers make nodejs npm python3 upx yarn"
ENV CONTAINERNAME "build"
ENV NODE_ENV      "development"
ENV PATH          "node_modules/.bin:/app/node_modules/.bin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin"
USER root
RUN mkdir /app
RUN $ALLOW_BUILD /app /tmp
RUN $PKG_INSTALL $PACKAGES
USER ${BUILD_USER}
WORKDIR /app