# Audit sécurité — Jour 1 Auth (LEYISA SCHOOL)

Date : 2026-06-14  
Branche : `Feat_Kev_and_Franck`  
Périmètre : Auth JWT, Docker local, Postman, logs audit

---

## 1. Contrôles exécutés

| Contrôle | Commande / méthode | Résultat |
|----------|-------------------|----------|
| Composer validate | `composer validate` | OK (warnings publication package — normal MVP) |
| Composer audit | `composer audit` | **Aucune vulnérabilité** |
| Lint YAML | `lint:yaml config/` | OK |
| Lint container | `lint:container` | OK |
| Routes | `debug:router` | `POST /api/login`, `GET /api/me` uniquement (API métier) |
| Schema Doctrine | `doctrine:schema:validate` | Mapping OK — DB légèrement désync (index + messenger) |
| `.env.local` | git check-ignore | **Non versionné** |
| Secrets réels | revue manuelle | Placeholders dev uniquement |
| Login OK | POST /api/login | 200 + JWT |
| Login KO | mauvais mdp / email | 401 `Invalid credentials.` |
| /api/me OK | Bearer valide | 200, sans password |
| /api/me KO | sans token | 401 `JWT Token not found` |
| /api/me KO | token invalide | 401 `Invalid JWT Token` |
| bcrypt cost 4 | `security.yaml` | **Uniquement `when@dev`** |
| APP_DEBUG=0 | `docker-compose.yml` | **Docker local uniquement** |

---

## 2. Tests API manuels

```
POST /api/login (admin@leyisa.test)     → 200 + token
GET  /api/me (Bearer)                  → 200, password absent
POST /api/login (mauvais password)     → 401 Invalid credentials.
POST /api/login (email inexistant)     → 401 Invalid credentials.
GET  /api/me (sans token)              → 401 JWT Token not found
GET  /api/me (token invalide)         → 401 Invalid JWT Token
```

**Bonnes pratiques respectées :**
- même message pour email inconnu et mauvais mot de passe (pas d'énumération)
- password jamais exposé dans `/api/me`
- compte inactif → message dédié via `UserChecker`

---

## 3. Audit fichiers Git

| Élément | Statut |
|---------|--------|
| `vendor/` | Ignoré — non commité |
| `var/` | Ignoré — non commité |
| `.env.local` | Ignoré — non commité |
| `config/jwt/*.pem` | Ignoré |
| `composer.lock` | Conservé (recommandé) |
| Migrations | Conservées |
| Guides Franck | Conservés |
| Doublons Docker (`compose.yaml`) | Supprimés précédemment — OK |
| Postman | Comptes test uniquement (`password123`) |

**Fichier lourd normal :** `composer.lock` (~400 Ko) — nécessaire.

**Amélioration `.gitignore` :** IDE, OS, `node_modules/`, `docker-compose.override.yml`.

---

## 4. Risques identifiés

| Risque | Niveau | Statut |
|--------|--------|--------|
| Schema Doctrine désync (index + messenger) | Faible | Documenté Jour 2 |
| Secrets dev dans `docker-compose.yml` | Faible | Acceptable dev local |
| `APP_DEBUG=0` masque erreurs en Docker | Faible | Volontaire perf |
| Pas de rate limiting login | Moyen | Futur (Jour 2+) |
| Pas de SIEM centralisé | Info | Préparation logs faite |

**Aucune faille critique** sur le périmètre Jour 1 Auth.

---

## 5. Corrections appliquées (audit)

1. **Canal Monolog `security_auth`** — fichier `var/log/security_auth.log` (dev)
2. **`AuthSecurityLoggerSubscriber`** — événements :
   - `auth.login.success`
   - `auth.login.failure` (invalid_credentials / inactive_account)
   - `auth.jwt.missing`
   - `auth.jwt.invalid`
3. **`.gitignore`** enrichi (IDE, OS, node_modules, override Docker)

**Jamais loggé :** password, token JWT, secrets.

---

## 6. Limites connues

- Logs locaux dans `var/log/` (volume Docker) — pas d'envoi SIEM
- Pas de corrélation ID requête / utilisateur centralisée
- Pas d'alerting automatique
- Performance dev dépend du bind mount Windows (mitigé par volumes Docker)

---

## 7. Préparation futur SIEM

Le canal `security_auth` en JSON sur stderr (prod) pourra être collecté par :

- Docker logging driver → ELK / Loki / CloudWatch
- Fluent Bit / Filebeat sur `security_auth.log`
- Export JSON structuré (`auth.login.success`, `auth.jwt.invalid`, etc.)

Champs utiles déjà présents : `ip`, `path`, `method`, `user_agent`, `email` (masqué), `reason`.

---

## 8. Performance post-audit

Objectif maintenu après changements :

- `POST /api/login` : ~100–300 ms (après 1er appel)
- `GET /api/me` : ~200–300 ms

---

## 9. Recommandation

**Commit recommandé** si validation Kevin OK :

```
chore(audit): clean backend structure and prepare security logging
```

Fichiers concernés : `.gitignore`, `monolog.yaml`, `AuthSecurityLoggerSubscriber.php`, ce document.
