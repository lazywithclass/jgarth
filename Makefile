testem:
	./node_modules/.bin/testem

test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script/register --reporter spec test

integration-test:
	java -Djava.library.path=$$(pwd)/test/integration/lib/DynamoDBLocal_lib \
	  -Djava.util.logging.config.file=/dev/null \
      -Dorg.eclipse.jetty.LEVEL=WARN \
      -Dlog4j.com.amazonaws.services.dynamodbv2.local.server.LocalDynamoDBServerHandler=OFF \
      -jar $$(pwd)/test/integration/lib/DynamoDBLocal.jar \
      -inMemory \
      -port 8000  &
	./node_modules/.bin/mocha --compilers coffee:coffee-script/register --reporter spec test/integration/main.coffee
	ps -ef | grep [D]ynamoDBLocal_lib | awk '{print $$2}' | xargs kill

.PHONY: test
