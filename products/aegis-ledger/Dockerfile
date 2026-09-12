FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
COPY aegis-domain aegis-domain
COPY aegis-application aegis-application
COPY aegis-app aegis-app
RUN mvn -B -pl aegis-app -am package -DskipTests

FROM eclipse-temurin:21-jre
RUN useradd --system --uid 10001 aegis
WORKDIR /app
COPY --from=build /workspace/aegis-app/target/aegis-app-*.jar /app/aegis-ledger.jar
USER 10001
EXPOSE 8080
ENTRYPOINT ["java","-XX:MaxRAMPercentage=75","-jar","/app/aegis-ledger.jar"]
