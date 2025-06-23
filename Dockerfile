FROM tomcat:9.0-jdk17

COPY target/vprofile-v2.war /usr/local/tomcat/webapps/vprofile.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
