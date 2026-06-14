# LEYISA SCHOOL — Backend (BackEndFlow)

Backend Symfony 7 — gestion scolaire MVP (RDC / EPST).

**Branche active :** `Feat_Kev_and_Franck`  
**Dépôt :** [VisioTechLab/BackEndFlow](https://github.com/VisioTechLab/BackEndFlow)

---

## Guides importants — Franck

> Commence par le **premier guide** ci-dessous. Tu n'as pas besoin de connaître Symfony pour tester.

| | Guide | Action |
|---|-------|--------|
| 1 | **[Lancer Docker et tester l'Auth](docs/guides/franck/LANCER_DOCKER_ET_TESTER_AUTH.md)** | Docker + Postman — **commencer ici** |
| 2 | **[Contribuer au backend](docs/guides/franck/CONTRIBUER_BACKEND.md)** | Règles MVP, architecture, interdictions |
| 3 | **[Installation Docker](docs/guides/devops/INSTALLATION_DOCKER.md)** | Dépannage Docker et performance |

**Postman :** importer les fichiers dans `postman/` puis choisir l'environnement **Leyisa School Local**.

**API :** http://127.0.0.1:8000

---

## État du projet (Jour 1)

| Fonctionnalité | Statut |
|----------------|--------|
| Auth JWT (`POST /api/login`) | OK |
| Profil (`GET /api/me`) | OK |
| Docker (app + MySQL + phpMyAdmin) | OK |
| 7 rôles + fixtures test | OK |
| Logs sécurité pré-SIEM | OK |
| Modules métier (élèves, notes…) | **Pas commencé** |

---

## Guides techniques (Kevin / dev)

| Guide | Description |
|-------|-------------|
| [Index documentation](docs/README.md) | Tous les guides |
| [Module Jour 1 Auth](docs/guides/modules/JOUR1_AUTH.md) | Endpoints et comptes test |
| [Architecture MVP](docs/architecture/ARCHITECTURE_BACKEND_MVP.md) | Référence architecture |
| [Audit sécurité](docs/security/AUDIT_JOUR1_AUTH.md) | Contrôles et logs |

---

## Démarrage rapide Docker

```bash
git checkout Feat_Kev_and_Franck
git pull origin Feat_Kev_and_Franck
docker compose up -d --build
docker compose exec app composer install
docker compose exec app php bin/console doctrine:database:create --if-not-exists
docker compose exec app php bin/console doctrine:migrations:migrate --no-interaction
docker compose exec app php bin/console doctrine:fixtures:load --no-interaction
```

Compte test : `admin@leyisa.test` / `password123`

---

## URLs locales

| Service | URL |
|---------|-----|
| API Symfony | http://127.0.0.1:8000 |
| MySQL (hôte) | 127.0.0.1:3307 |
| phpMyAdmin | http://127.0.0.1:8080 |

---

*LEYISA SCHOOL — VisioTechLab*
