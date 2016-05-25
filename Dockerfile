FROM rails:4.2.5

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES 1

WORKDIR /rails/cedar

ADD Gemfile ./Gemfile
ADD Gemfile.lock ./Gemfile.lock

RUN bundle install --without development test

ADD . ./

RUN chmod 755 ./rails-entrypoint.sh

EXPOSE 3000
