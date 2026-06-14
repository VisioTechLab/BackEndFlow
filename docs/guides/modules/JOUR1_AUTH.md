# Module Jour 1 — Auth / Utilisateurs / Rôles

> Référence technique. Pour tester avec Docker et Postman, voir le [guide Franck](../franck/LANCER_DOCKER_ET_TESTER_AUTH.md).

## Endpoints

| Methode | URL | Auth | Description |
|---------|-----|------|-------------|
| POST | `/api/login` | Public | Connexion JWT (`email`, `password`) |
| GET | `/api/me` | Bearer JWT | Profil utilisateur connecte |

## Setup local (Docker — recommandé)

```bash
docker compose up -d --build
docker compose exec app composer install
docker compose exec app php bin/console doctrine:database:create --if-not-exists
docker compose exec app php bin/console doctrine:migrations:migrate --no-interaction
docker compose exec app php bin/console doctrine:fixtures:load --no-interaction
```

API : http://127.0.0.1:8000

## Setup local (sans Docker — Kevin uniquement)

```bash
composer install
php bin/console doctrine:database:create --if-not-exists
php bin/console doctrine:migrations:migrate --no-interaction
php bin/console doctrine:fixtures:load --no-interaction
php -S 127.0.0.1:8000 -t public
```

## Comptes de test (dev uniquement)

Mot de passe commun : `password123`

| Email | Role |
|-------|------|
| admin@leyisa.test | ROLE_ADMIN |
| direction@leyisa.test | ROLE_DIRECTION |
| enseignant@leyisa.test | ROLE_ENSEIGNANT |
| parent@leyisa.test | ROLE_PARENT |
| eleve@leyisa.test | ROLE_ELEVE |
| comptable@leyisa.test | ROLE_COMPTABLE |
| surveillant@leyisa.test | ROLE_SURVEILLANT |

## Exemple Postman — login

```json
POST /api/login
{
  "email": "admin@leyisa.test",
  "password": "password123"
}
```

Reponse : token JWT + utilisateur (sans password).

## Exemple — me

```
GET /api/me
Authorization: Bearer <token>
```
