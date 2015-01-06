#SHELL := /bin/bash

# will be used as default as long as it's the first
testem: git-hooks
	./node_modules/.bin/testem

git-hooks: 
	ln -fs `pwd`/git-hooks/pre-commit .git/hooks/pre-commit

test: git-hooks
	./node_modules/.bin/mocha --compilers coffee:coffee-script/register --reporter spec test --stack_trace_limit 10

integration-test: git-hooks
	{ java -Djava.library.path=$$(pwd)/test/integration/lib/DynamoDBLocal_lib \
      -Djava.util.logging.config.file=/dev/null \
      -Dorg.eclipse.jetty.LEVEL=WARN \
      -Dlog4j.com.amazonaws.services.dynamodbv2.local.server.LocalDynamoDBServerHandler=OFF \
      -jar $$(pwd)/test/integration/lib/DynamoDBLocal.jar \
      -inMemory \
      -port 8000 & }; \
    pid=$$!; \
    sleep 3; \
    ./node_modules/.bin/mocha --compilers coffee:coffee-script/register \
      --reporter spec \
      --timeout 5000 \
      test/integration/main.coffee; \
    r=$$?; \
    kill $$pid; \
    exit $$r

.PHONY: test git-hooks integration-test
