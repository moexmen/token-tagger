# syntax=docker/dockerfile:experimental

FROM ruby:2.7.2-alpine AS gems
COPY Gemfile Gemfile.lock ./
RUN --mount=type=ssh \
    apk --no-cache add --virtual build-dependencies \
               build-base \
               postgresql-dev \
               libxml2-dev \
               libxslt-dev \
    && gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" \
    # && bundle config set --local deployment 'true' \
    && bundle config set --local without 'development test' \
    && bundle install \
    && apk del build-dependencies

FROM ruby:2.7.2-alpine AS ci-gems
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

FROM ruby:2.7.2-alpine AS ci
RUN apk --no-cache add chromium chromium-chromedriver
COPY --from=ci-gems /usr/local/bundle /usr/local/bundle
COPY --chown=app:nogroup . .
USER app

FROM ruby:2.7.2-alpine AS gold
COPY --from=gems /usr/local/bundle /usr/local/bundle
COPY --chown=app:nogroup . .
ENV RAILS_ENV production
RUN --mount=type=ssh \
    adduser -S -h /app -u 10000 app \
    && apk --no-cache add \
        bash \
        curl \
        git \
        libxml2 \
        libxslt \
        nodejs \
        openssh-client \
        postgresql-client \
        tzdata \
    && apk --no-cache add --virtual build-dependencies \
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
