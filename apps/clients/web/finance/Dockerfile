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
    apt-get install -y gcsfuse; \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update -y && \
    apt-get install google-cloud-sdk -y \
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

COPY --chown=nextjs:nodejs dist/$APP_DIR/.next/standalone ./
COPY --chown=nextjs:nodejs dist/$APP_DIR/public ./$APP_DIR/public
COPY --chown=nextjs:nodejs dist/$APP_DIR/.next/static ./dist/$APP_DIR/.next/static
COPY --chown=nextjs:nodejs $APP_DIR/gcsfuse.sh ./

EXPOSE $PORT

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

# Pass the startup script as arguments to Tini
CMD ["/app/gcsfuse.sh"]
