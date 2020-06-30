# FormBuilder Product Page

Product Pages are no longer live. For infomation on MoJ Form Builder please contact form-builder-team@digital.justice.gov.uk .

## Running Locally

If you wish to run in your own browser, you'll need to run the
following commands from the root of this project:

- `bundle install` to install middleman and its dependencies
- `npm install` to install the frontend dependencies
- `bundle exec middleman server` - to start middleman's built in server
- `open http://localhost:4567` - to open the example in your browser

## Application Deployment

To deploy you will need to

1. Build docker image
2. Push docker image to ECR
3. Delete pods, so new containers are spun with the new docker image

Build docker image and push to ECR with one command:
```sh
./scripts/build_and_push
```

Delete pods with the following command:
```sh
./scripts/restart
```

## Infrastructure deployment

If you need to apply kubernetes changes, call the following command:
```sh
./scripts/deploy
```

On the very rare occasion you need to initialise the kubernetes deployment:
```sh
./scripts/create
```
