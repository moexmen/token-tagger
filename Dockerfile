# syntax=docker/dockerfile:experimental

FROM ruby:2.7-alpine AS gems
COPY Gemfile Gemfile.lock ./
RUN --mount=type=ssh \
    apk --no-cache add --virtual build-dependencies \
               build-base \
               postgresql-dev \
               libxml2-dev \
               libxslt-dev \
    && gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" \
    && bundle config set --local deployment 'true' \
    && bundle config set --local without 'development test' \
    && bundle install \
    && apk del build-dependencies

FROM ruby:2.7-alpine AS ci-gems
COPY Gemfile Gemfile.lock ./
RUN --mount=type=ssh \
    apk --no-cache add --virtual build-dependencies \
               build-base \
               postgresql-dev \
               libxml2-dev \
               libxslt-dev \
    && gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" \
    && bundle install \
    && gem install --conservative brakeman bundler-audit nokogiri \
    && apk del build-dependencies

FROM ruby:2.7-alpine AS ci
COPY --from=ci-gems /usr/local/bundle /usr/local/bundle
COPY --chown=app:nogroup . .
RUN --mount=type=ssh \
    apk --no-cache add --virtual build-dependencies \
        yarn
RUN --mount=type=ssh \
    apk --no-cache add chromium chromium-chromedriver
RUN yarn install --check-files
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver
USER app

FROM ruby:2.7-alpine AS gold
COPY --from=gems /usr/local/bundle /usr/local/bundle
COPY --from=gems /app/vendor/bundle vendor/bundle
COPY --chown=app:nogroup . .
ENV RAILS_ENV production
RUN --mount=type=ssh \
    apk --no-cache add --virtual build-dependencies \
        yarn \
    && SECRET_KEY_BASE=1a bundle exec rails assets:precompile \
    && apk del build-dependencies \
    && mkdir -p tmp/pids \
    && chown -R app /app
USER app
EXPOSE 3000
ARG TAG
ENV TAG ${TAG:-0000}
ARG BUILD_TIME
ENV BUILD_TIME ${BUILD_TIME}
ENV DEFACEMENT_STRING "aGiGHB3nM8IlIpNQGc4vS82unOeNRucV"
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]