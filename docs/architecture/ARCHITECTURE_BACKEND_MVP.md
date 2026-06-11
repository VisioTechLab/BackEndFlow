# LEYISA SCHOOL - Architecture Backend MVP (version officielle)

**Stack :** Symfony 7, PHP 8.2+, MySQL 8, Doctrine ORM  
**API :** `/api/v1`  
**Authentification MVP :** JWT (LexikJWTAuthenticationBundle)  
**Tenant :** 1 ecole = 1 client SaaS (table `ecole`)

**Statut :** architecture validee — `database/leyisa_mvp.sql` est prepare, aligne avec l'architecture MVP, et pret pour validation/migrations.

---

## A. Architecture corrigee validee

Monolithe Symfony organise par **domaine metier**, avec couches strictes :

```
Controller -> Service metier -> Repository -> Entity
```

**Decisions officielles :**
- Auth MVP = **JWT uniquement**
- Cloisonnement SaaS via **TenantContext** + **id_ecole** sur tables sensibles
- **TenantCoherenceValidator** obligatoire avant toute ecriture metier liee
- **id_ecole** jamais accepte depuis le JSON client
- **Scolarite** = AnneeScolaire, Classe, Eleve, Inscription
- **Pedagogie** = Matiere, Periode, Enseignement, Evaluation, Note
- Aucune logique metier dans les Controllers
- `find($id)` seul interdit sur donnees metier
- Pas de triggers SQL tenant au MVP (coherence = code + tests)

---

## B. Arborescence finale complete

```
Leyisa_2.0/
|-- bin/
|-- config/
|   |-- packages/
|   |   |-- doctrine.yaml
|   |   |-- lexik_jwt_authentication.yaml
|   |   |-- security.yaml
|   |-- routes/
|       |-- api_v1.yaml
|-- database/
|   |-- leyisa_mvp.sql              # Prepare, aligne MVP, pret migrations
|-- docs/
|   |-- architecture/
|-- migrations/
|-- public/
|-- src/
|   |-- Kernel.php
|   |
|   |-- Ecole/
|   |   |-- Controller/
|   |   |   |-- EcoleController.php
|   |   |-- Entity/
|   |   |   |-- Ecole.php
|   |   |-- Repository/
|   |   |   |-- EcoleRepository.php
|   |   |-- Service/
|   |   |   |-- EcoleService.php
|   |   |-- DTO/
|   |       |-- UpdateEcoleRequest.php
|   |
|   |-- Utilisateur/
|   |   |-- Controller/
|   |   |   |-- AuthController.php          # POST /login, GET /me
|   |   |   |-- UtilisateurController.php
|   |   |   |-- ProfesseurController.php
|   |   |-- Entity/
|   |   |   |-- Utilisateur.php
|   |   |   |-- Professeur.php
|   |   |-- Repository/
|   |   |   |-- UtilisateurRepository.php
|   |   |   |-- ProfesseurRepository.php
|   |   |-- Service/
|   |   |   |-- UtilisateurService.php
|   |   |   |-- AuthService.php
|   |   |-- DTO/
|   |   |-- Security/
|   |       |-- UtilisateurProvider.php
|   |
|   |-- Scolarite/
|   |   |-- Controller/
|   |   |   |-- AnneeScolaireController.php
|   |   |   |-- ClasseController.php
|   |   |   |-- EleveController.php
|   |   |   |-- InscriptionController.php
|   |   |-- Entity/
|   |   |   |-- AnneeScolaire.php
|   |   |   |-- Classe.php
|   |   |   |-- Eleve.php
|   |   |   |-- Inscription.php
|   |   |-- Repository/
|   |   |-- Service/
|   |   |   |-- InscriptionService.php
|   |   |   |-- EleveService.php
|   |   |-- DTO/
|   |
|   |-- Pedagogie/
|   |   |-- Controller/
|   |   |   |-- MatiereController.php
|   |   |   |-- PeriodeController.php
|   |   |   |-- EnseignementController.php
|   |   |   |-- EvaluationController.php
|   |   |   |-- NoteController.php
|   |   |-- Entity/
|   |   |   |-- Matiere.php
|   |   |   |-- Periode.php
|   |   |   |-- Enseignement.php
|   |   |   |-- Evaluation.php
|   |   |   |-- Note.php
|   |   |-- Repository/
|   |   |-- Service/
|   |   |   |-- MatiereService.php
|   |   |   |-- PeriodeSeedService.php
|   |   |   |-- EnseignementService.php
|   |   |   |-- EvaluationService.php
|   |   |   |-- NoteService.php
|   |   |-- DTO/
|   |   |-- Security/
|   |       |-- EnseignementVoter.php
|   |       |-- NoteVoter.php
|   |
|   |-- Publication/
|   |   |-- Controller/
|   |   |   |-- PublicationController.php
|   |   |   |-- BulletinController.php
|   |   |-- Entity/
|   |   |   |-- PublicationPeriode.php
|   |   |   |-- BulletinArchive.php
|   |   |   |-- BulletinArchiveLigne.php
|   |   |-- Repository/
|   |   |-- Service/
|   |   |   |-- PublicationService.php
|   |   |   |-- BulletinCalculService.php
|   |   |   |-- BulletinArchiveService.php
|   |   |   |-- BulletinPdfService.php
|   |   |-- DTO/
|   |
|   |-- Audit/
|   |   |-- Controller/
|   |   |   |-- AuditLogController.php
|   |   |-- Entity/
|   |   |   |-- AuditLog.php
|   |   |-- Repository/
|   |   |-- Service/
|   |       |-- AuditLogService.php
|   |
|   |-- Shared/
|       |-- Tenant/
|       |   |-- TenantContext.php
|       |   |-- TenantSubscriber.php
|       |   |-- TenantAwareRepository.php
|       |   |-- TenantAwareInterface.php
|       |   |-- TenantCoherenceValidator.php
|       |-- Enum/
|       |   |-- RoleUser.php
|       |   |-- StatutPublication.php
|       |   |-- TypeBulletin.php
|       |   |-- StatutAnnee.php
|       |   |-- StatutInscription.php
|       |-- Exception/
|       |   |-- DomainException.php
|       |   |-- NoteLockedException.php
|       |   |-- TenantAccessDeniedException.php
|       |   |-- TenantCoherenceException.php
|       |-- Response/
|       |   |-- ApiResponse.php
|       |-- Security/
|           |-- JwtAuthenticationSuccessHandler.php
|
|-- tests/
|   |-- Unit/
|   |-- Functional/
|
|-- var/
```

---

## C. Justification des corrections

| Correction | Justification |
|------------|---------------|
| Matiere + Periode dans **Pedagogie** | Servent aux evaluations, notes et bulletins EPST |
| Scolarite = Annee, Classe, Eleve, Inscription | Structure + parcours eleve |
| **id_ecole** sur tables sensibles | Filtre tenant direct, sans jointures multiples |
| **TenantCoherenceValidator** | Empeche les incoherences cross-tenant a l'ecriture |
| **id_ecole** jamais depuis JSON | Le client ne choisit jamais l'ecole |
| **classe** : niveau + option + lettre | Plusieurs niveaux peuvent avoir une classe "A" |
| **matiere** : UNIQUE(ecole, designation) | Une ecole ne duplique pas le meme libelle |
| JWT uniquement | Decision officielle MVP |
| Pas de triggers SQL | Coherence tenant = Services + tests Postman |

---

## D. Tables MVP finales avec id_ecole

| Table | Domaine | id_ecole |
|-------|---------|----------|
| ecole | Tenant | - (racine) |
| utilisateur | Utilisateur | OUI |
| professeur | Utilisateur | OUI |
| annee_scolaire | Scolarite | OUI |
| classe | Scolarite | OUI |
| eleve | Scolarite | OUI |
| inscription | Scolarite | OUI |
| matiere | Pedagogie | OUI |
| periode | Pedagogie | OUI |
| enseignement | Pedagogie | OUI |
| evaluation | Pedagogie | OUI |
| note | Pedagogie | OUI |
| publication_periode | Publication | OUI |
| bulletin_archive | Publication | OUI |
| bulletin_archive_ligne | Publication | via bulletin |
| audit_log | Audit | OUI |

**Classe** : champs `niveau_classe`, `option_classe` (`GENERALE` si sans option specifique), `lettre_classe`.

---

## E. Contraintes SQL finales

```sql
UNIQUE (id_ecole, code_user)                                    -- utilisateur
UNIQUE (id_ecole, email_user)                                   -- utilisateur
UNIQUE (id_ecole, matricule_prof)                               -- professeur
UNIQUE (id_ecole, matricule_eleve)                              -- eleve
UNIQUE (id_ecole, code_periode)                                 -- periode
UNIQUE (id_ecole, id_annee, niveau_classe, option_classe, lettre_classe)  -- classe
UNIQUE (id_ecole, designation)                                  -- matiere
UNIQUE (id_eleve, id_annee)                                     -- inscription
UNIQUE (id_prof, id_matiere, id_classe, id_annee)               -- enseignement
UNIQUE (id_eleve, id_evaluation)                                -- note
UNIQUE (id_classe, id_periode)                                  -- publication_periode
UNIQUE (id_inscription, type_bulletin)                          -- bulletin_archive
UNIQUE (id_bulletin_archive, id_matiere)                         -- bulletin_archive_ligne
```

---

## F. Index recommandes

| Index | Tables |
|-------|--------|
| `idx_*_ecole (id_ecole)` | Toutes les tables metier avec id_ecole |
| `idx_inscription_ecole_annee (id_ecole, id_annee)` | inscription |
| `idx_note_ecole_eleve (id_ecole, id_eleve)` | note |
| `idx_audit_utilisateur (id_utilisateur)` | audit_log |
| `idx_*_annee (id_annee)` | classe, inscription, enseignement |
| `idx_*_classe (id_classe)` | inscription, enseignement, publication |
| `idx_*_eleve (id_eleve)` | inscription, note |
| `idx_*_prof (id_prof)` | enseignement |
| `idx_*_matiere (id_matiere)` | enseignement, bulletin_archive_ligne |
| `idx_*_evaluation (id_evaluation)` | note |
| `idx_*_inscription (id_inscription)` | bulletin_archive |
| `idx_bulletin_type (type_bulletin)` | bulletin_archive |
| `idx_bulletin_hash (hash_pdf)` | bulletin_archive |
| `idx_audit_created (created_at)` | audit_log |

---

## G. Regles TenantContext et TenantCoherence

### TenantContext

**Emplacement :** `src/Shared/Tenant/TenantContext.php`

```
Login JWT -> payload -> Utilisateur -> Ecole -> TenantContext
```

**Regles :**
1. Rempli apres authentification JWT (`TenantSubscriber`)
2. A la **creation** : `id_ecole` force depuis TenantContext, **jamais** depuis le JSON client
3. A la **lecture** : repositories utilisent `findOneByIdAndEcole($id, $ecole)`
4. A la **modification** : verifier que l'entite appartient a l'ecole connectee
5. Prof : Voters limitent au perimetre enseignement

### Regle JSON client (obligatoire)

- Le champ `id_ecole` **ne doit jamais** etre accepte dans les DTO / requetes metier.
- `id_ecole` vient **toujours** du `TenantContext`.
- Si le client envoie `id_ecole`, il est **ignore** (DTO sans ce champ) ou la requete est **refusee**.

### TenantCoherenceValidator (obligatoire Module 1)

**Emplacement :** `src/Shared/Tenant/TenantCoherenceValidator.php`

**Role :**
- verifier que les entites liees ont le meme `id_ecole`
- verifier l'alignement avec le `TenantContext`
- lever `TenantCoherenceException` en cas d'incoherence

**Usage dans les Services :**

```php
$this->tenantCoherenceValidator->validate(
    [$eleve, $classe, $anneeScolaire],
    'inscription'
);
```

| Operation | Entites a verifier |
|-----------|-------------------|
| **inscription** | eleve, classe, annee_scolaire |
| **professeur** | utilisateur, professeur |
| **enseignement** | professeur, matiere, classe, annee_scolaire |
| **evaluation** | enseignement, periode |
| **note** | eleve, evaluation |
| **publication_periode** | classe, periode |
| **bulletin_archive** | inscription, published_by (utilisateur) |
| **bulletin_archive_ligne** | matiere + bulletin_archive (meme ecole) |

**Pas de triggers SQL au MVP.** La coherence tenant est assuree par :
- `TenantContext`
- `TenantCoherenceValidator`
- Services metier
- Tests Postman cross-tenant

### Repositories

**Dangereux en SaaS :**
```php
$this->repository->find($id);  // [X] INTERDIT
```

**Correct :**
```php
$this->repository->findOneByIdAndEcole($id, $tenantContext->getEcole());  // [OK]
$this->repository->findByEcole($tenantContext->getEcole());
$this->repository->findByClasseAndEcole($classe, $tenantContext->getEcole());
```

---

## H. Regles Controller / Service / Repository

### Controller (couche HTTP)
- Recevoir la requete HTTP
- Valider le DTO d'entree (**sans id_ecole**)
- Appeler le **Service**
- Retourner JSON (via `ApiResponse`)
- **Interdit :** regles metier, calcul EPST, blocage notes, audit, TenantCoherence

### Service (couche metier)
| Service | Responsabilite |
|---------|----------------|
| NoteService | Modifiable ? Blocage apres publication + TenantCoherence |
| PublicationService | Publier classe/periode + TenantCoherence |
| BulletinCalculService | Totaux, rang, mention |
| BulletinArchiveService | Scellement + hash_pdf + TenantCoherence, insert-only |
| BulletinPdfService | Generation / lecture PDF (reimpression sans recalcul) |
| AuditLogService | Tracabilite actions sensibles |
| InscriptionService | Unicite eleve/annee + TenantCoherence |
| EnseignementService | Unicite quadruple + TenantCoherence |

Chaque Service d'ecriture appelle `TenantCoherenceValidator` **avant** `persist()`.

### Repository (couche acces donnees)
- Requetes Doctrine uniquement
- Herite de `TenantAwareRepository` quand applicable
- Toujours filtrer par `id_ecole`

---

## I. Immutabilite des archives EPST

Les tables `bulletin_archive` et `bulletin_archive_ligne` sont considerees comme des **archives scellees**.

Regles obligatoires :
- Elles doivent fonctionner en mode **insert-only**.
- Toute modification directe apres generation est **interdite**, sauf procedure exceptionnelle controlee, auditee et validee par un service metier.
- La reimpression d'un bulletin doit **toujours** lire les donnees archivees (`bulletin_archive`, `bulletin_archive_ligne`, `chemin_pdf`), **sans recalculer** les notes vivantes.
- `chemin_pdf` et `hash_pdf` sont **obligatoires** a la creation de l'archive.

---

## J. Decisions officielles a retenir

| Sujet | Decision |
|-------|----------|
| Auth MVP | **JWT uniquement** (`POST /api/v1/login`, `GET /api/v1/me`) |
| Tenant | `ecole` = client SaaS, `id_ecole` sur tables sensibles |
| id_ecole client | **Jamais** accepte depuis le JSON |
| Coherence tenant | `TenantCoherenceValidator` obligatoire |
| Triggers SQL | **Non** au MVP |
| Domaines | Scolarite vs Pedagogie separes (voir section B) |
| Couches | Controller -> Service -> Repository -> Entity |
| Archives EPST | Scellees, insert-only, reimpression sans recalcule |
| Hors MVP | Parents, SMS, presences, paiements, QR complet |
| SQL | `database/leyisa_mvp.sql` prepare, aligne, pret migrations |
| Roles SQL | `ADMIN_ECOLE`, `PROFESSEUR` |
| Roles Symfony | `ROLE_ADMIN_ECOLE`, `ROLE_PROFESSEUR` |
| Mot de passe | Jamais retourne en API |

---

## K. Module 1 — tests obligatoires (Postman)

Avant de merger `feature/module-socle`, ces scenarios doivent passer :

| # | Scenario | Resultat attendu |
|---|----------|------------------|
| 1 | Creation avec `id_ecole` envoye dans le JSON | Ignore ou refuse (422) ; `id_ecole` pris du TenantContext |
| 2 | Lecture d'une ressource d'une autre ecole (ID devine) | 403 ou 404 |
| 3 | Inscription : eleve ecole A + classe ecole B | `TenantCoherenceException` (422) |
| 4 | Enseignement : prof ecole A + matiere ecole B | `TenantCoherenceException` (422) |
| 5 | Login JWT valide + GET /api/v1/me | 200, ecole correcte dans la reponse |
| 6 | Requete sans token sur route protegee | 401 |

---

## L. Prochaine etape

1. **Valider** ce document avec Kevin et Franck
2. **Initialiser** projet Symfony 7 + Lexik JWT
3. **Migrer** depuis `database/leyisa_mvp.sql`
4. **Integrer** `TenantContext`, `TenantCoherenceValidator`, auth JWT
5. **Executer** les tests Postman section K
6. **Branch** `feature/module-socle` -> merge apres tests OK

---

*Document officiel LEYISA SCHOOL MVP — version corrigee et validee.*
