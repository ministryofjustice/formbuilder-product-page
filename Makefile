.PHONEY: all build clean build-docker

all: clean build build-docker run-docker

docker-go-away: remove-docker-containers remove-docker-images

build-and-deploy: clean build live-deploy

build:
	@echo "Build..."
	# git pull
	bundle install
	npm install
	bundle exec middleman build --clean

clean:
	@echo "tidy up..."
	rm -rf node_modules/
	rm -rf build/

build-docker:
	docker build -t product-pages .

remove-docker-images:
	@echo "removing product-pages images"
	docker rmi product-pages

run-docker:
	# docker run -d -P --name product-pages product-pages
	docker run -d --name product-pages -p 4567:4567 product-pages
	docker port product-pages

run-docker-bash:
	docker run --name product-pages -it product-pages /bin/bash

remove-docker-containers:
	@echo "removing product-pages containers"
	docker stop product-pages
	docker rm product-pages

live-deploy:
	@echo "Building Image..."
	docker build -t formbuilder/formbuilder-product-page .
	@echo "Tagging Image..."
	docker tag formbuilder/formbuilder-product-page:latest 754256621582.dkr.ecr.eu-west-2.amazonaws.com/formbuilder/formbuilder-product-page:latest
	@echo "Pushing Image..."
	docker push 754256621582.dkr.ecr.eu-west-2.amazonaws.com/formbuilder/formbuilder-product-page:latest
	@echo "Restarting pod..."
	./scripts/restart
	