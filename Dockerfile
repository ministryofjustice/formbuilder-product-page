FROM ministryofjustice/ruby:2.5.3-webapp-onbuild

RUN apt-get update && apt-get install -y nodejs

RUN bundle install

EXPOSE 4567

ENTRYPOINT bundle exec middleman server
