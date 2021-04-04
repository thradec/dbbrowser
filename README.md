[![CI](https://github.com/thradec/dbbrowser/workflows/CI/badge.svg)](https://github.com/thradec/dbbrowser/actions)

# DBBrowser

Simple API for browsing database structures, currently with support for PostgreSQL.


## Prerequisites

* Java 11
* Docker


## How to build and test

```shell
$ ./mvnw clean verify
```


## How to run

* for quick testing with H2 in-memory database:

```shell
$ ./mvnw spring-boot:run
```

* or with PostgreSQL:

```shell
$ ./mvnw spring-boot:run -Dspring-boot.run.jvmArguments=" \
      -Dspring.datasource.url=jdbc:postgresql://localhost:5432/postgres \ 
      -Dspring.datasource.username=postgres \
      -Dspring.datasource.password=******"
```


## API documentation

* http://localhost:8080/swagger-ui.html
* http://localhost:8080/v3/api-docs


## TODOs

* security
* improve logging  
* improve documentation  
* handle unusual/large data types
* support another database types
* support data pagination  
* storing credentials
* consider metadata caching
* consider statistics pre-calculation  
* tests with large database
* tests necessary permissions for database user