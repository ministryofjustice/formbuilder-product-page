FROM ministryofjustice/ruby:2.5.3-webapp-onbuild

RUN apt-get update && apt-get install -y nodejs

COPY package*.json ./

RUN bundle install

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get -y install npm

EXPOSE 4567

ENTRYPOINT bundle exec middleman server
