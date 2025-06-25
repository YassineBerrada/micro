# Étape 1 : image de base légère avec JDK
FROM openjdk:17-jdk-slim

# Étape 2 : argument pour le .jar (remplacé lors du build si nécessaire)
ARG JAR_FILE=target/*.jar

# Étape 3 : copie du jar compilé dans l'image
COPY ${JAR_FILE} app.jar

# Étape 4 : point d’entrée
ENTRYPOINT ["java", "-jar", "app.jar"]
