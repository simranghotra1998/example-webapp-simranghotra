FROM java:8-alpine
MAINTAINER Simran ghotra <skaurghotra8@gmail.com>

ADD target/uberjar/example-webapp.jar /example-webapp/app.jar

EXPOSE 3000

CMD ["java", "-jar", "/example-webapp/app.jar"]
