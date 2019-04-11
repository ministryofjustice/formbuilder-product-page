FROM ministryofjustice/ruby:2.5.3-webapp-onbuild

RUN apt-get update && apt-get install -y nodejs

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get -y install npm

RUN groupadd -r deploy && useradd -m -u 999 -r -g deploy deploy
RUN chown -R deploy:deploy .
RUN find $GEM_HOME ! -user deploy | xargs chown -R deploy:deploy
USER deploy

RUN bundle install

RUN npm install --unsafe-perm

EXPOSE 4567

ENTRYPOINT bundle exec middleman server

USER deploy
