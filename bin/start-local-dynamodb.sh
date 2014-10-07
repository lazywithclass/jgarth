#!/bin/bash

java -Djava.library.path=$(pwd)/test/integration/lib/DynamoDBLocal_lib \
     -jar $(pwd)/test/integration/lib/DynamoDBLocal.jar \
     -inMemory \
     -port 8000
