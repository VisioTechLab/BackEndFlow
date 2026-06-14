# Installation Docker — LEYISA SCHOOL Backend

## Prérequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installé et démarré
- Git

## Démarrage rapide

```bash
# 1. Lancer les conteneurs
docker compose up -d --build

# 2. Installer les dépendances PHP
docker compose exec app composer install

# 3. Préparer la base de données
docker compose exec app php bin/console doctrine:database:create --if-not-exists
docker compose exec app php bin/console doctrine:migrations:migrate --no-interaction
docker compose exec app php bin/console doctrine:fixtures:load --no-interaction

# 4. Vider le cache
docker compose exec app php bin/console cache:clear
```

## URLs

| Service | URL |
|---------|-----|
| API Symfony | http://127.0.0.1:8000 |
| MySQL (depuis l'hôte) | 127.0.0.1:3307 |
| phpMyAdmin | http://127.0.0.1:8080 |

## Connexion base de données

| Paramètre | Valeur |
|-----------|--------|
| Host (depuis Windows) | 127.0.0.1 |
| Port | 3307 |
| User | root |
| Password | root |
| Base | leyisa_mvp |

Dans Docker (service `app`), la variable est :

```
DATABASE_URL=mysql://root:root@database:3306/leyisa_mvp?serverVersion=8.0.36&charset=utf8mb4
```

## Tests API rapides

```bash
# Login
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@leyisa.test\",\"password\":\"password123\"}"

# Me (remplacer TOKEN)
curl http://127.0.0.1:8000/api/me -H "Authorization: Bearer TOKEN"
```

## Commandes utiles

```bash
docker compose ps
docker compose logs -f app
docker compose down
docker compose down -v   # supprime aussi le volume MySQL
```

## Problèmes fréquents

### Port 3306 déjà utilisé (XAMPP)

Docker MySQL utilise le port **3307** sur votre machine. XAMPP peut rester sur 3306.

### Port 8000 déjà utilisé

Arrêtez l'autre service ou changez le mapping dans `docker-compose.yml` :

```yaml
ports:
  - "8001:8000"
```

### MySQL pas encore prêt

Attendez 20–30 secondes après `docker compose up`, puis relancez les commandes Doctrine.

### Erreur JWT

Les variables JWT sont définies dans `docker-compose.yml` (dev uniquement). Relancez :

```bash
docker compose exec app php bin/console cache:clear
```

### Migrations / fixtures oubliées

Sans fixtures, le login échouera (aucun utilisateur). Relancez les commandes de la section « Démarrage rapide ».

## Postman

Voir `docs/guides/FRANCK_TEST_AUTH_POSTMAN.md` et importer les fichiers dans `postman/`.
