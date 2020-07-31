# MOJ Online Product Page

![Deploy to Production](https://github.com/ministryofjustice/formbuilder-product-page/workflows/Deploy%20to%20Production/badge.svg)

https://formbuilder-product-page.apps.live-1.cloud-platform.service.justice.gov.uk/

For information on MOJ Online please contact moj-online@digital.justice.gov.uk.

## Running Locally

If you wish to run in your own browser, you'll need to run the
following commands from the root of this project:

- `\curl -sSL https://get.rvm.io | bash` to install ruby version manager (rvm)
- `cat .ruby-version | xargs rvm install` to install the correct version of ruby
- `gem install bundler` to install the dependency manager
- `bundle install` to install middleman and its dependencies
- `npm install` to install the frontend dependencies
- `bundle exec middleman server` - to start middleman's built in server
- `open http://localhost:4567` - to open the example in your browser

## Deployment

Deployments are handled by [Github Actions](https://github.com/ministryofjustice/formbuilder-product-page/actions).

Any branch except master will deploy to the staging environment. This can be visited [here](https://formbuilder-product-page-staging.apps.live-1.cloud-platform.service.justice.gov.uk/)

Once a change is pushed or merged to master then production will automatically be deployed.
