# Guide Franck — Lancer Docker et tester l’Auth

> **Pour qui ?** Franck — débutant accepté.  
> **But ?** Lancer le projet avec Docker et tester le login JWT avec Postman.  
> **Branche ?** `Feat_Kev_and_Franck`

---

## 1. Objectif de Franck

Tu dois **tester le module Auth du Jour 1** avec Docker et Postman.

Concrètement :

- Vérifier que les **connexions** fonctionnent (`POST /api/login`)
- Vérifier que le **profil utilisateur** s’affiche (`GET /api/me`)
- Vérifier que les **rôles** sont corrects (Admin, Direction, Enseignant, etc.)
- Vérifier que les **erreurs** sont bien refusées (401)

**Tu ne dois pas modifier le cœur du code** (entités, sécurité, migrations, Docker).  
Si tu as un doute, demande à Kevin avant de changer un fichier.

---

## 2. Prérequis

Avant de commencer, vérifie que tu as :

| Outil | Statut |
|-------|--------|
| **Git** | Installé |
| **Docker Desktop** | Installé **et démarré** (icône verte) |
| **Postman** | Installé |
| **Accès GitHub** | Dépôt `VisioTechLab/BackEndFlow` |
| **Branche** | `Feat_Kev_and_Franck` |

---

## 3. Récupérer le projet

### Cas A — Tu as déjà le projet sur ton PC

Ouvre un terminal (PowerShell) dans le dossier du projet, puis :

```bash
git checkout Feat_Kev_and_Franck
git pull origin Feat_Kev_and_Franck
```

### Cas B — Tu n’as pas encore le projet

```bash
git clone https://github.com/VisioTechLab/BackEndFlow.git
cd BackEndFlow
git checkout Feat_Kev_and_Franck
```

Ensuite, place-toi **toujours** dans le dossier du projet avant les commandes Docker.

---

## 4. Lancer Docker

Dans le dossier du projet :

```bash
docker compose up -d --build
```

**Ce que fait cette commande :**

| Service | Rôle |
|---------|------|
| **app** | API Symfony (PHP) |
| **database** | MySQL |
| **phpmyadmin** | Interface web pour voir la base (optionnel) |

La première fois, le build peut prendre **plusieurs minutes**. C’est normal.

Attends **30 à 60 secondes** après la fin avant les commandes suivantes.

---

## 5. Vérifier les conteneurs

```bash
docker compose ps
```

**Résultat attendu :** les 3 services sont **Up**.

Exemple :

```
leyisa_app          Up
leyisa_database     Up (healthy)
leyisa_phpmyadmin   Up
```

Si un service n’est pas `Up`, attends 1 minute et relance `docker compose ps`.  
Si ça ne marche toujours pas → voir section 13 ou contacte Kevin.

---

## 6. Préparer le projet dans Docker

Lance les commandes **dans l’ordre** (copie-colle une par une) :

```bash
docker compose exec app composer install
```

```bash
docker compose exec app php bin/console doctrine:database:create --if-not-exists
```

```bash
docker compose exec app php bin/console doctrine:migrations:migrate --no-interaction
```

```bash
docker compose exec app php bin/console doctrine:fixtures:load --no-interaction
```

```bash
docker compose exec app php bin/console cache:clear
```

```bash
docker compose exec app php bin/console cache:warmup --no-debug
```

**À quoi servent les fixtures ?**  
Elles créent **7 comptes de test** (Admin, Direction, Enseignant, etc.) avec le mot de passe `password123`.

Si on te demande de confirmer la purge de la base → réponds **yes**.

---

## 7. Adresse de l’API

L’API est disponible ici :

```
http://127.0.0.1:8000
```

**Important :** utilise **`127.0.0.1`** et **pas** `localhost` dans Postman.  
Sur Windows, `localhost` peut être plus lent.

**Routes utiles :**

| Méthode | URL |
|---------|-----|
| POST | `http://127.0.0.1:8000/api/login` |
| GET | `http://127.0.0.1:8000/api/me` |

**phpMyAdmin (optionnel) :** http://127.0.0.1:8080  
(user : `root` / password : `root`)

---

## 8. Importer Postman

1. Ouvre **Postman**
2. Clique sur **Import**
3. Importe ces 2 fichiers (dans le dossier `postman/` du projet) :

```
postman/Leyisa_School_Jour1_Auth.postman_collection.json
postman/Leyisa_School_Local.postman_environment.json
```

4. En haut à droite, choisis l’environnement :

```
Leyisa School Local
```

Sans cet environnement, les variables `{{base_url}}` et `{{token}}` ne marcheront pas.

---

## 9. Tester Login Admin

1. Ouvre la collection **Leyisa School Jour1 Auth**
2. Clique sur **Login Admin**
3. Clique sur **Send**

**Résultat attendu :**

- Status : **200 OK**
- Body JSON avec un champ `"token": "eyJ..."`
- Onglet **Test Results** : tests verts

**Compte utilisé :**

| Champ | Valeur |
|-------|--------|
| Email | `admin@leyisa.test` |
| Mot de passe | `password123` |

Le script Postman enregistre le token automatiquement pour la requête suivante.

---

## 10. Tester GET /api/me

1. **Juste après** Login Admin, ouvre **GET /api/me**
2. Vérifie le header :

```
Authorization: Bearer {{token}}
```

3. Clique sur **Send**

**Résultat attendu :**

- Status : **200 OK**
- `email` visible
- `roles` visible (ex. `ROLE_ADMIN`)
- `idEcole` visible
- **`password` absent** — très important

Le mot de passe ne doit **jamais** apparaître dans la réponse.

---

## 11. Tester tous les rôles

Mot de passe commun pour tous : **`password123`**

| Requête Postman | Email |
|-----------------|-------|
| Login Admin | `admin@leyisa.test` |
| Login Direction | `direction@leyisa.test` |
| Login Enseignant | `enseignant@leyisa.test` |
| Login Parent | `parent@leyisa.test` |
| Login Eleve | `eleve@leyisa.test` |
| Login Comptable | `comptable@leyisa.test` |
| Login Surveillant | `surveillant@leyisa.test` |

**Pour chaque rôle :**

1. Lance le **Login** correspondant
2. Puis lance **GET /api/me**
3. Vérifie que le **rôle** affiché correspond

---

## 12. Tester les erreurs

Dans Postman, lance ces requêtes :

| Requête | Résultat attendu |
|---------|------------------|
| Test mauvais mot de passe | **401** Unauthorized |
| Test email inexistant | **401** Unauthorized |
| Test /api/me sans token | **401** Unauthorized |
| Test /api/me token invalide | **401** Unauthorized |

Message typique pour login échoué :

```json
{
  "code": 401,
  "message": "Invalid credentials."
}
```

C’est **normal** : on ne dit pas si l’email existe ou non (sécurité).

---

## 13. Si Postman est lent

Essaie dans cet ordre :

1. Utilise **`http://127.0.0.1:8000`** (pas `localhost`)
2. Attends que Docker soit totalement démarré (`docker compose ps`)
3. Relance **Login Admin** une 2e fois (le 1er appel peut être plus lent)
4. Redémarre le conteneur app :

```bash
docker compose restart app
```

5. Si besoin, relance le cache :

```bash
docker compose exec app php bin/console cache:clear
docker compose exec app php bin/console cache:warmup --no-debug
```

Après warmup, le login devrait répondre en **~100 à 300 ms**.

---

## 14. Voir les logs sécurité

Pour voir les tentatives de connexion (audit) :

```bash
docker compose exec app cat var/log/security_auth.log
```

**Exemples de lignes :**

- `auth.login.success` → connexion réussie
- `auth.login.failure` → mauvais email ou mot de passe
- `auth.jwt.missing` → accès `/api/me` sans token
- `auth.jwt.invalid` → token invalide

**Important :** ces logs ne contiennent **jamais** :

- le mot de passe
- le token JWT complet
- un secret

L’email est **masqué** (ex. `ad***@leyisa.test`).

---

## 15. Ce que Franck ne doit pas modifier

Sauf validation explicite de Kevin, **ne touche pas** à :

| Fichier / dossier | Pourquoi |
|-------------------|----------|
| `src/Utilisateur/Entity/User.php` | Entité utilisateur |
| `src/Ecole/Entity/Ecole.php` | Entité école |
| `config/packages/security.yaml` | Règles de sécurité |
| `config/packages/lexik_jwt_authentication.yaml` | Configuration JWT |
| `migrations/` | Structure base de données |
| `Dockerfile` | Image Docker |
| `docker-compose.yml` | Services Docker |

Tu peux utiliser Postman, lancer Docker et remplir le rapport de tests.

---

## 16. Résultat attendu à envoyer à Kevin

Copie ce modèle, remplis-le et envoie-le à Kevin :

```
Tests Franck — Jour 1 Auth

* Docker lancé : Oui / Non
* Login Admin : OK / Erreur
* GET /api/me : OK / Erreur
* Password absent : Oui / Non
* Login Direction : OK / Erreur
* Login Enseignant : OK / Erreur
* Login Parent : OK / Erreur
* Login Élève : OK / Erreur
* Login Comptable : OK / Erreur
* Login Surveillant : OK / Erreur
* Mauvais mot de passe = 401 : Oui / Non
* Token invalide = 401 : Oui / Non
* Problème rencontré :
* Capture ou message d'erreur :
```

---

## Aide rapide

| Problème | Solution |
|----------|----------|
| Docker ne démarre pas | Ouvre Docker Desktop |
| Login 401 | Relance les fixtures (section 6) |
| GET /api/me 401 | Relance Login Admin d’abord |
| Variables `{{...}}` visibles telles quelles | Sélectionne l’environnement **Leyisa School Local** |

**Autres guides :**

- [Installation Docker](../devops/INSTALLATION_DOCKER.md) — détails techniques Docker
- [Contribuer au backend](./CONTRIBUER_BACKEND.md) — règles d'architecture pour Franck
- [Audit sécurité Jour 1](../../security/AUDIT_JOUR1_AUTH.md) — audit Auth

---

*Guide LEYISA SCHOOL — Kevin & Franck — Jour 1 Auth*
