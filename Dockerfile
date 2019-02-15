FROM ministryofjustice/ruby:2.5.3-webapp-onbuild

RUN bundle install

RUN apt-get update && apt-get install -y nodejs

EXPOSE 4567

ENTRYPOINT bundle exec middleman server
