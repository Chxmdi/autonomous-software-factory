.PHONY: up down seed run verify domain-smoke

up:
	docker compose up -d postgres

down:
	docker compose down

seed:
	PGPASSWORD=aegis-local-only psql -h localhost -U aegis -d aegis -f scripts/seed-demo.sql

run:
	SPRING_PROFILES_ACTIVE=local mvn -pl aegis-app -am spring-boot:run

verify:
	mvn -B verify

domain-smoke:
	./scripts/verify-domain.sh
