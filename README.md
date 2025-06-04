# MOJ Forms Product Page

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/ministryofjustice/formbuilder-product-page/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/ministryofjustice/formbuilder-product-page/tree/main)

https://moj-forms.service.justice.gov.uk

For information on MOJ Forms please contact moj-forms@justice.gov.uk.

## Running Locally

If you wish to run in your own browser, you'll need to run the
following commands from the root of this project:

- `brew install rbenv ruby-build` to install ruby version manager (rbenv)
- `rbenv init` to load rbenv in your shell, follow the printed instructions
- `cat .ruby-version | xargs rbenv install` to install the correct version of ruby
- `gem install bundler` to install the dependency manager
- `bundle install` to install middleman and its dependencies
- `npm install` to install the frontend dependencies
- `bundle exec middleman server` - to start middleman's built in server
- `open http://localhost:4567` - to open the example in your browser

## Deployment

Deployments are handled by [CircleCI](https://github.com/ministryofjustice/formbuilder-product-page/blob/main/.circleci/config.yml).

Any branch except main will deploy to the staging environment. This can be visited [here](https://formbuilder-product-page-staging.apps.live.cloud-platform.service.justice.gov.uk/)

Once a change is pushed or merged to main then production will automatically be deployed.

The environment variables required in CircleCI - check the [Tech Docs](https://ministryofjustice.github.io/moj-forms-tech-docs/#runbooks) for more infomation.

## Making Content Changes without Installing Middleman and Other Tools (well maybe a text editor)
Add this repo to git desktop
Create a new branch for your changes
Open the files in source/ and update the html
Add your changes to the branch
Commit changes and push up

This will trigger an action to build the site in [staging](https://formbuilder-product-page-staging.apps.live.cloud-platform.service.justice.gov.uk/).
