# Module Jour 1 — Auth / Utilisateurs / Roles

## Endpoints

| Methode | URL | Auth | Description |
|---------|-----|------|-------------|
| POST | `/api/login` | Public | Connexion JWT (`email`, `password`) |
| GET | `/api/me` | Bearer JWT | Profil utilisateur connecte |

## Setup local

```bash
composer install
php bin/console lexik:jwt:generate-keypair --overwrite
php bin/console doctrine:database:create --if-not-exists
php bin/console doctrine:migrations:migrate --no-interaction
php bin/console doctrine:fixtures:load --no-interaction
php -S localhost:8000 -t public
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
