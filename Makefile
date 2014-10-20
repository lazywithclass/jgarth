# will be used as default as long as it's the first
testem: git-hooks
	./node_modules/.bin/testem

git-hooks: 
	ln -fs `pwd`/git-hooks/pre-commit .git/hooks/pre-commit

test: git-hooks
	./node_modules/.bin/mocha --compilers coffee:coffee-script/register --reporter spec test

integration-test: git-hooks
	java -Djava.library.path=$$(pwd)/test/integration/lib/DynamoDBLocal_lib \
		-Djava.util.logging.config.file=/dev/null \
		-Dorg.eclipse.jetty.LEVEL=WARN \
		-Dlog4j.com.amazonaws.services.dynamodbv2.local.server.LocalDynamoDBServerHandler=OFF \
		-jar $$(pwd)/test/integration/lib/DynamoDBLocal.jar \
		-inMemory \
		-port 8000  &
	sleep 3
# a - in front command doesnt exit from the target
# if command exits with an error code
	-./node_modules/.bin/mocha \
		--compilers coffee:coffee-script/register \
		--reporter spec test/integration/main.coffee
	ps -ef | grep [D]ynamoDBLocal_lib | awk '{print $$2}' | xargs kill

.PHONY: test git-hooks
