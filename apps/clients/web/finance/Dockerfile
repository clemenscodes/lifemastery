FROM node:16 as runner

RUN set -e; \
    apt-get update -y && apt-get install -y \
    tini \
    curl \
    tree \
    gnupg \
    lsb-release; \
    gcsFuseRepo=gcsfuse-`lsb_release -c -s`; \
    echo "deb http://packages.cloud.google.com/apt $gcsFuseRepo main" | \
    tee /etc/apt/sources.list.d/gcsfuse.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    apt-key add -; \
    apt-get update; \
    apt-get install -y gcsfuse \
    && apt-get clean

ENV APP_HOME /app
ENV APP finance
ENV PORT 3000
ENV HOST=0.0.0.0
ENV HOSTNAME=localhost
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV APP_DIR apps/clients/web/$APP
ENV BUCKET lifemastery

WORKDIR $APP_HOME

RUN addgroup nodejs
RUN adduser nextjs

COPY --chown=nextjs:nodejs dist/$APP_DIR/.next/standalone/$APP_DIR ./$APP_DIR
COPY --chown=nextjs:nodejs dist/$APP_DIR/.next/standalone/libs ./libs
COPY --chown=nextjs:nodejs dist/$APP_DIR/.next/standalone/package.json ./
COPY --chown=nextjs:nodejs dist/$APP_DIR/.next/standalone/node_modules ./node_modules
COPY --chown=nextjs:nodejs $APP_DIR/gcsfuse.sh ./

EXPOSE $PORT

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

# Pass the startup script as arguments to Tini
CMD ["/app/gcsfuse.sh"]
