# Guide Franck — Tester l'authentification avec Postman

Ce guide explique comment lancer le backend avec **Docker** et tester le **Module Jour 1 Auth** avec Postman.

---

## 1. Installer Docker Desktop

Télécharge et installe [Docker Desktop](https://www.docker.com/products/docker-desktop/).

Lance Docker Desktop et attends qu'il soit **Running** (icône verte).

---

## 2. Ouvrir le terminal dans le projet

Ouvre PowerShell ou le terminal Cursor dans le dossier du projet :

```
C:\xampp\htdocs\Visio_Tech_product\Leyisa_2.0
```

---

## 3. Lancer Docker

```bash
docker compose up -d --build
```

Attends 20–30 secondes que MySQL soit prêt.

---

## 4. Installer les dépendances PHP

```bash
docker compose exec app composer install
```

---

## 5. Préparer la base de données

```bash
docker compose exec app php bin/console doctrine:database:create --if-not-exists
docker compose exec app php bin/console doctrine:migrations:migrate --no-interaction
docker compose exec app php bin/console doctrine:fixtures:load --no-interaction
```

Réponds **yes** si on te demande de purger la base.

---

## 6. Vérifier l'API

Ouvre dans le navigateur ou Postman :

```
http://127.0.0.1:8000
```

L'API doit répondre (page Symfony ou erreur 404 sur `/` — c'est normal).

---

## 7. Ouvrir Postman

Installe [Postman](https://www.postman.com/downloads/) si ce n'est pas déjà fait.

---

## 8. Importer la collection

1. Postman → **Import**
2. Choisis le fichier :
   ```
   postman/Leyisa_School_Jour1_Auth.postman_collection.json
   ```

---

## 9. Importer l'environnement

1. Postman → **Import**
2. Choisis :
   ```
   postman/Leyisa_School_Local.postman_environment.json
   ```

---

## 10. Choisir l'environnement

En haut à droite de Postman, sélectionne **Leyisa School Local**.

---

## 11. Lancer Login Admin

1. Ouvre la requête **Login Admin**
2. Clique **Send**
3. Vérifie : statut **200** et un **token** dans la réponse JSON

Le script Postman enregistre automatiquement le token dans la variable `token`.

---

## 12. Lancer GET /api/me

1. Ouvre **GET /api/me**
2. Clique **Send**
3. Vérifie le profil :
   - email visible
   - rôles visibles
   - idEcole visible
   - **password jamais visible**

---

## 13. Tester les autres requêtes

| Requête | Résultat attendu |
|---------|------------------|
| Login Direction / Enseignant / etc. | 200 + token |
| Test mauvais mot de passe | 401 |
| Test email inexistant | 401 |
| Test /api/me sans token | 401 |
| Test /api/me token invalide | 401 |

---

## Comptes de test

Mot de passe commun : **password123**

| Email | Rôle |
|-------|------|
| admin@leyisa.test | ROLE_ADMIN |
| direction@leyisa.test | ROLE_DIRECTION |
| enseignant@leyisa.test | ROLE_ENSEIGNANT |
| parent@leyisa.test | ROLE_PARENT |
| eleve@leyisa.test | ROLE_ELEVE |
| comptable@leyisa.test | ROLE_COMPTABLE |
| surveillant@leyisa.test | ROLE_SURVEILLANT |

---

## Problèmes fréquents

### Port 3306 déjà utilisé par XAMPP

Docker utilise le port **3307** pour MySQL. Pas besoin d'arrêter XAMPP.

### Conteneur MySQL pas encore prêt

Attends 30 secondes après `docker compose up`, puis relance les commandes Doctrine.

### Migrations non lancées

Erreur « table utilisateur doesn't exist » → relance les commandes de la section 5.

### Fixtures non chargées

Login échoue (401) → relance `doctrine:fixtures:load`.

### Token absent dans Postman

Vérifie que l'environnement **Leyisa School Local** est sélectionné. Relance **Login Admin**.

### Erreur 401 sur /api/me

Le token a expiré ou est vide. Relance **Login Admin** avant **GET /api/me**.

### Docker ne démarre pas

Vérifie que Docker Desktop est ouvert et en cours d'exécution.

---

## phpMyAdmin (optionnel)

```
http://127.0.0.1:8080
```

- Serveur : `database`
- Utilisateur : `root`
- Mot de passe : `root`

---

*Guide LEYISA SCHOOL — Franck & Kevin*
