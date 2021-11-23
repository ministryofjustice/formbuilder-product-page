# MOJ Forms Product Page

![Deploy to Production](https://github.com/ministryofjustice/formbuilder-product-page/workflows/Deploy%20to%20Production/badge.svg)

https://moj-forms.service.justice.gov.uk

For information on MOJ Forms please contact moj-forms@digital.justice.gov.uk.

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

The environment variables required in Github secrets are found in the `.github/workflows` folder. There are 2 clusters, K8S and EKS.
The only differing values between the two clusters are:
- CLUSTER_NAME
- TOKEN
- CLUSTER_CERT

To get the correct values we need to ensure we are in the appropriate context, `live` or `live-1`, and then run the following commands:

For the CLUSTER_CERT:
`kubectl -n <NAMESPACE> get secrets <NAME-OF-GITHUBACTION-SERVICE-ACCOUNT-SECRET> -o json | grep ca.crt`

For the TOKEN:
`cloud-platform decode-secret -n <NAMESPACE> -s <NAME-OF-GITHUBACTION-SERVICE-ACCOUNT-SECRET> | grep token`

The CLUSTER_NAME is the same as the other apps and can be found by running the `pipeline_variables.sh` script in the `fb-deploy` repo.

## Making Content Changes without Installing Middleman and Other Tools (well maybe a text editor)
Add this repo to git desktop
Create a new branch for your changes
Open the files in source/ and update the html
Add your changes to the branch
Commit changes and push up

This will trigger an action to build the site in [staging](https://formbuilder-product-page-staging.apps.live-1.cloud-platform.service.justice.gov.uk/).
