# Guide Backend pour Franck — LEYISA SCHOOL MVP

---

## 1. Objectif du guide

Ce guide t'aide à contribuer au backend LEYISA SCHOOL **sans te perdre** et **sans casser l'architecture**.

Points importants :

- L'**architecture** est déjà validée (`docs/architecture/ARCHITECTURE_BACKEND_MVP.md`).
- La **BDD MVP** est déjà validée (`database/leyisa_mvp.sql`).
- Tu **ne dois pas modifier la conception** (architecture, SQL) sans validation de Kevin.
- Ton rôle : aider sur les **parties simples**, les **tests Postman**, les **fixtures** et la **documentation**.

Si tu as un doute, **demande avant de coder**.

---

## 2. Rappel du MVP

Le cœur du MVP est cette chaîne métier :

```text
inscrire ? enseigner ? noter ? publier ? archiver ? réimprimer
```

Modules **hors MVP — interdits pour l'instant** :

```text
parents
paiements
présences
notifications SMS/WhatsApp
portail parent
portail élève
QR code complet
microservices
```

Ne les ajoute pas, même « pour tester ».

---

## 3. Architecture officielle à respecter

Arborescence officielle :

```text
src/
  Ecole/
  Utilisateur/
  Scolarite/
  Pedagogie/
  Publication/
  Audit/
  Shared/
```

Rôle de chaque domaine :

```text
Ecole       = tenant / client SaaS
Utilisateur = auth, utilisateurs, professeurs
Scolarite   = année, classe, élève, inscription
Pedagogie   = matière, période, enseignement, évaluation, note
Publication = publication, bulletin, archive
Audit       = trace des actions sensibles
Shared      = éléments communs : TenantContext, exceptions, enums
```

Chaque domaine contient des sous-dossiers : `Controller/`, `Entity/`, `Repository/`, `Service/`, `DTO/` (et parfois `Security/`).

---

## 4. Règle de code obligatoire

Couches strictes :

```text
Controller ? Service ? Repository ? Entity
```

Définitions simples :

```text
Controller = reçoit la requête API
Service    = applique la règle métier
Repository = interroge la BDD
Entity     = représente la table
DTO        = contrôle les données reçues
```

**Règle stricte :** tu ne mets **pas** la logique métier directement dans un Controller.

Exemple correct :

```text
Controller ? valide le DTO ? appelle MatiereService ? retourne JSON
Service    ? vérifie les règles ? appelle le Repository
Repository ? findOneByIdAndEcole(...)
```

Exemple incorrect :

```text
Controller ? calcule les totaux, bloque les notes, écrit en BDD directement
```

---

## 5. Règle SaaS obligatoire

LEYISA SCHOOL est un SaaS : **1 école = 1 client (tenant)**.

Règles :

```text
id_ecole ne vient jamais du JSON client.
id_ecole vient toujours du TenantContext.
```

**Interdit :**

```php
$repository->find($id);
```

**Préférer :**

```php
$repository->findOneByIdAndEcole($id, $ecole);
```

Toute donnée créée doit appartenir à **l'école connectée**.  
Avant une écriture liée (inscription, enseignement, note…), Kevin validera l'usage de `TenantCoherenceValidator`.

---

## 6. Ce que Franck peut toucher plus tard

| Zone | Franck peut aider ? | Condition |
| --------------------------------------- | ------------------------- | ------------------------------- |
| `docs/guides/` | Oui | Documentation |
| `docs/postman/` | Oui | Tests API |
| `src/Scolarite/Controller/` | Oui plus tard | CRUD simples validés |
| `src/Scolarite/DTO/` | Oui plus tard | DTO simples |
| `src/Scolarite/Service/` | Oui avec validation Kevin | Pas de règle sensible seul |
| `src/Pedagogie/Controller/` | Oui plus tard | Matiere, Periode simples |
| `src/Pedagogie/DTO/` | Oui plus tard | DTO simples |
| `database/leyisa_mvp.sql` | Non | Seulement avec validation Kevin |
| `src/Shared/Tenant/` | Non seul | Partie sensible SaaS |
| `src/Utilisateur/Security/` | Non seul | Sécurité JWT |
| `src/Publication/Service/` | Non seul | Bulletin/archive sensible |
| `src/Pedagogie/Service/NoteService.php` | Non seul | Blocage note sensible |

---

## 7. Ce que Franck ne doit pas toucher seul

```text
database/leyisa_mvp.sql
docs/architecture/ARCHITECTURE_BACKEND_MVP.md
TenantContext
TenantCoherenceValidator
JWT / sécurité
NoteService
PublicationService
BulletinCalculService
BulletinArchiveService
AuditLogService
Migrations Doctrine
```

Ces fichiers sont **sensibles**. Toute modification doit être **validée avec Kevin** avant commit.

---

## 8. Les tâches adaptées à Franck

Tu peux aider sur :

```text
CRUD simples
DTO simples
fixtures
tests Postman
documentation
captures de résultats
vérification des erreurs
```

Exemples de tâches adaptées :

```text
Créer la documentation d'un endpoint
Préparer une collection Postman
Tester un CRUD
Documenter les réponses JSON
Créer des fixtures simples
Vérifier qu'un professeur n'accède pas à une autre école
```

---

## 9. Exemple de tâche : CRUD Matiere

**Domaine :**

```text
src/Pedagogie/
```

**Fichiers possibles plus tard :**

```text
MatiereController
MatiereService
MatiereRepository
CreateMatiereRequest
UpdateMatiereRequest
```

**Règles :**

```text
Une matière appartient à une école.
Deux matières ne doivent pas avoir le même nom dans une même école.
id_ecole vient du TenantContext.
```

**Tests Postman :**

```text
Admin crée une matière ? 201
Admin crée une matière déjà existante ? 409
Professeur crée une matière ? 403
id_ecole envoyé dans JSON ? ignoré ou refusé
```

---

## 10. Exemple de tâche : CRUD Eleve

**Domaine :**

```text
src/Scolarite/
```

**Fichiers possibles plus tard :**

```text
EleveController
EleveService
EleveRepository
CreateEleveRequest
UpdateEleveRequest
```

**Règles :**

```text
Un élève appartient à une école.
Le matricule élève est obligatoire.
Deux élèves ne doivent pas avoir le même matricule dans une même école.
id_ecole vient du TenantContext.
```

**Tests Postman :**

```text
Admin crée élève ? 201
Matricule déjà utilisé ? 409
Professeur crée élève ? 403
Lecture élève autre école ? 404 ou 403
```

---

## 11. Format de documentation Postman

Utilise ce modèle pour chaque test :

```text
Endpoint :
Méthode :
Rôle autorisé :
Body JSON :
Résultat attendu :
Résultat obtenu :
Statut : OK / À corriger
Capture :
Commentaire :
```

Exemple :

```text
Endpoint : /api/v1/matieres
Méthode : POST
Rôle autorisé : ADMIN_ECOLE
Body JSON : { "designation": "Mathématiques", "maxPeriode": 10, "maxExamen": 20 }
Résultat attendu : 201 Created
Résultat obtenu : 201 Created
Statut : OK
Capture : (joindre capture Postman)
Commentaire : Matière créée avec succès, id_ecole non envoyé dans le body.
```

---

## 12. Checklist avant de dire « j'ai fini »

Vérifie :

```text
Le fichier est dans le bon dossier.
Le nom respecte le lexique officiel.
Le Controller ne contient pas de logique métier.
Le Service applique la règle.
Le Repository filtre par école.
id_ecole n'est pas accepté depuis le JSON.
Le password_hash n'est jamais retourné.
Le cas normal est testé.
Le cas erreur est testé.
Le cas autre école est testé.
Le résultat est documenté.
```

---

## 13. Règle Git pour Franck

```text
Toujours faire git status avant de modifier.
Ne jamais travailler directement sur main.
Faire une branche claire si demandé.
Faire un commit petit et propre.
Ne pas mélanger code, SQL et documentation dans le même commit sans raison.
```

Branche de travail actuelle : **`Feat_Kev_and_Franck`** (ou une branche feature dédiée si Kevin le demande).

Exemples de messages de commit :

```text
docs: add backend guide for Franck
test: add Postman cases for eleve endpoints
feat: add matiere CRUD
fix: validate duplicate eleve matricule
```

---

## 14. Phrase finale pour Franck

> Le but n'est pas de coder vite. Le but est de coder proprement sans casser l'architecture MVP.  
> Si tu ne sais pas où mettre un fichier, demande avant de coder.

---

*Guide LEYISA SCHOOL MVP — Franck & Kevin — branche `Feat_Kev_and_Franck`*
