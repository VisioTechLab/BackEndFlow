# LEYISA SCHOOL � Annexe technique MVP

**Document compl�mentaire au Guide MVP Backend**  
**Auteurs : Kevin BITUBISHA / Franck � �quipe Backend**  
**Objectif : expliquer comment coder le MVP sans se tromper**

> Le guide principal explique *pourquoi* on fait le MVP.  
> Cette annexe explique *comment* le coder avec les m�mes r�gles pour toute l'�quipe.

---

## 1. Lexique officiel MCD ? Backend Symfony

**R�gle : ces noms sont d�finitifs. Ne pas en inventer d'autres.**

| Concept m�tier | Association / entit� MCD (Merise) | Entit� Symfony (PHP) | Table SQL |
|----------------|-------------------------------------|----------------------|-----------|
| �cole cliente (tenant SaaS) | ECOLE | `Ecole` | `ecole` |
| Compte de connexion | UTILISATEUR | `Utilisateur` | `utilisateur` |
| Professeur | PROFESSEUR | `Professeur` | `professeur` |
| �l�ve (identit� scolaire, sans compte MVP) | ELEVE | `Eleve` | `eleve` |
| Ann�e scolaire | ANNEE | `AnneeScolaire` | `annee` |
| Niveau d'�tude | NIVEAU | `NiveauEtude` | `niveau_etude` |
| Option d'�tude | OPTION | `OptionEtude` | `option_etude` |
| Classe | CLASSE | `Classe` | `classe` |
| Mati�re | MATIERE | `Matiere` | `matiere` |
| P�riode EPST (P1, P2, EXAM_S1�) | PERIODE | `Periode` | `periode` |
| Inscription �l�ve ? classe ? ann�e | INSCRIRE | `Inscription` | `inscription` |
| Affectation prof + mati�re + classe + ann�e | ENSEIGNER | `Enseignement` | `enseignement` |
| �valuation (TP, interro, devoir�) | EVALUER | `Evaluation` | `evaluation` |
| Note d'un �l�ve sur une �valuation | NOTER | `Note` | `note` |
| Verrouillage r�sultats par classe/p�riode | PUBLIER | `PublicationPeriode` | `publication_periode` |
| Bulletin EPST scell� | BULLETIN_ARCHIVE | `BulletinArchive` | `bulletin_archive` |
| Ligne mati�re du bulletin archiv� | DETAILLER_BULLETIN | `BulletinArchiveLigne` | `bulletin_archive_ligne` |
| Journal des actions sensibles | AUDITER | `AuditLog` | `audit_log` |

**Convention Symfony :**
- Entit�s : PascalCase singulier (`Inscription`, pas `Inscrire`)
- Tables : snake_case (`inscription`)
- Colonnes FK : `id_ecole`, `id_eleve`, `id_annee`, etc.

---

## 2. Contraintes importantes de la base de donn�es

### 2.1 Tenant SaaS � �COLE = client

- Toute donn�e m�tier appartient � **une seule �cole**.
- L'utilisateur connect� ne voit **jamais** les donn�es d'une autre �cole.
- Colonnes `id_ecole` obligatoires sur (minimum) :
  - `utilisateur`, `eleve`, `classe`, `matiere`, `inscription`, `enseignement`, `evaluation`, `bulletin_archive`, `audit_log`

**Unicit�s par �cole :**
```sql
UNIQUE (id_ecole, code_user)        -- utilisateur
UNIQUE (id_ecole, matricule_eleve)  -- �l�ve (matricule interne �cole)
```

### 2.2 Inscription � ann�e obligatoire

```
Inscription = �l�ve + classe + ann�e scolaire (+ �cole)
```

```sql
UNIQUE (id_eleve, id_annee)  -- 1 inscription principale par �l�ve et par ann�e
```

### 2.3 Enseignement � ann�e obligatoire

```
Enseignement = professeur + mati�re + classe + ann�e scolaire (+ �cole)
```

```sql
UNIQUE (id_prof, id_matiere, id_classe, id_annee)
```

### 2.4 �valuation � rattach�e � un enseignement

- Une �valuation appartient � **un enseignement** (pas seulement � une mati�re).
- Un professeur ne cr�e/consulte que les �valuations de **ses** enseignements.

### 2.5 Note � une valeur par �l�ve et par �valuation

```sql
UNIQUE (id_eleve, id_evaluation)
```

- `autorisation_modif` = `true` seulement pour d�rogation admin (avec audit).

### 2.6 Publication � verrouillage

- `PublicationPeriode` : une entr�e par `(classe, p�riode)`.
- Statuts : `BROUILLON` | `PUBLIE`.
- Apr�s `PUBLIE` : les notes de cette classe/p�riode sont **bloqu�es** sauf d�rogation.

### 2.7 Bulletin archiv� � types EPST

Types autoris�s : `S1` | `S2` | `ANNUEL`

```sql
UNIQUE (id_inscription, type_bulletin)
```

- Bulletin **scell�** : donn�es fig�es + `chemin_pdf` + `hash_pdf`.
- R�impression = lecture de l'archive, **jamais** recalcul depuis les notes vivantes.

### 2.8 �l�ve � pas de compte MVP

| Entit� | Compte login MVP ? |
|--------|-------------------|
| ADMIN_ECOLE | Oui (`Utilisateur`) |
| PROFESSEUR | Oui (`Utilisateur` ? `Professeur`) |
| �L�VE | **Non** � identit� dans `Eleve` uniquement |
| PARENT | **Non** � hors MVP |

---

## 3. R�gles de droits (RBAC MVP)

| Action | Admin �cole | Professeur |
|--------|:-----------:|:----------:|
| G�rer l'�cole (param�tres) | Oui | Non |
| G�rer les classes | Oui | Non |
| G�rer les �l�ves | Oui | Non |
| G�rer les professeurs / utilisateurs | Oui | Non |
| G�rer les mati�res | Oui | Non |
| G�rer les inscriptions | Oui | Non |
| Cr�er un enseignement (affectation) | Oui | Non |
| Cr�er une �valuation | Oui | Oui *(ses enseignements seulement)* |
| Saisir / modifier une note | Non | Oui *(ses classes, avant publication)* |
| Autoriser modification note apr�s publication | Oui | Non |
| Publier les r�sultats (classe + p�riode) | Oui | Non |
| G�n�rer / archiver bulletin PDF | Oui | Non |
| R�imprimer un bulletin archiv� | Oui | Lecture seule *(optionnel MVP)* |
| Consulter `AuditLog` | Oui | Non |

**Impl�mentation Symfony :** `IsGranted`, Voters (`EnseignementVoter`, `NoteVoter`), jamais seulement le r�le dans le contr�leur.

---

## 4. Endpoints API principaux (MVP)

Pr�fixe sugg�r� : `/api` � auth JWT ou session Symfony.

### Module 1 � Socle & s�curit�
| M�thode | Route | R�le | Description |
|---------|-------|------|-------------|
| POST | `/api/login` | Public | Connexion |
| GET | `/api/me` | Auth | Utilisateur + �cole + r�le |
| POST | `/api/utilisateurs` | Admin | Cr�er utilisateur / prof |
| GET | `/api/professeurs` | Admin | Liste professeurs |
| GET | `/api/audit-logs` | Admin | Journal audit |

### Module 2 � Structure scolaire
| M�thode | Route | R�le | Description |
|---------|-------|------|-------------|
| CRUD | `/api/annees` | Admin | Ann�es scolaires |
| CRUD | `/api/classes` | Admin | Classes |
| CRUD | `/api/matieres` | Admin | Mati�res |
| GET | `/api/periodes` | Auth | P�riodes EPST (seed) |

### Module 3 � Scolarit�
| M�thode | Route | R�le | Description |
|---------|-------|------|-------------|
| CRUD | `/api/eleves` | Admin | �l�ves |
| CRUD | `/api/inscriptions` | Admin | Inscriptions (�l�ve + classe + ann�e) |

### Module 4 � Enseignement & notes
| M�thode | Route | R�le | Description |
|---------|-------|------|-------------|
| CRUD | `/api/enseignements` | Admin | Affectations prof |
| CRUD | `/api/evaluations` | Admin / Prof | �valuations |
| GET/POST/PATCH | `/api/notes` | Prof | Saisie notes (scope enseignement) |

### Module 5 � Publication & bulletin
| M�thode | Route | R�le | Description |
|---------|-------|------|-------------|
| POST | `/api/publications` | Admin | Publier classe + p�riode |
| POST | `/api/bulletins/generer` | Admin | Calcul + PDF + archive |
| GET | `/api/bulletins/{id}` | Admin / Prof | D�tail archive |
| GET | `/api/bulletins/{id}/pdf` | Admin / Prof | R�impression PDF |

---

## 5. Crit�res de fin par module (Definition of Done)

### Module 1 � Socle
- [ ] Admin se connecte et re�oit un token/session valide
- [ ] Admin cr�e un professeur li� � son �cole
- [ ] Mauvais mot de passe / token absent / r�le interdit ? erreur claire
- [ ] Action sensible enregistr�e dans `audit_log`

### Module 2 � Structure
- [ ] CRUD classes, mati�res, ann�es avec `id_ecole`
- [ ] Seed p�riodes EPST : P1, P2, EXAM_S1, P3, P4, EXAM_S2
- [ ] Donn�es de test r�alistes (1 �cole, 2 classes, 5 mati�res)

### Module 3 � Scolarit�
- [ ] CRUD �l�ves sans compte utilisateur
- [ ] Inscription �l�ve + classe + ann�e
- [ ] Rejet si double inscription `(id_eleve, id_annee)`

### Module 4 � Notes
- [ ] Prof ne voit que ses enseignements / �valuations / notes
- [ ] Saisie et modification note avant publication OK
- [ ] Modification apr�s publication bloqu�e (sauf `autorisation_modif` + audit)

### Module 5 � Bulletin
- [ ] Publication passe statut ? `PUBLIE`
- [ ] G�n�ration PDF + �criture `bulletin_archive` + lignes mati�res
- [ ] `hash_pdf` calcul� et stock�
- [ ] R�impression archive sans recalcul
- [ ] Unicit� `(id_inscription, type_bulletin)` respect�e

---

## 6. Sc�nario de d�mo MVP (5 minutes)

1. Admin se connecte.
2. Admin cr�e une classe et inscrit 3 �l�ves.
3. Admin affecte un prof � une mati�re/classe/ann�e.
4. Prof se connecte, cr�e une �valuation, saisit les notes.
5. Admin publie la p�riode S1.
6. Admin g�n�re le bulletin S1 ? PDF archiv�.
7. Admin r�imprime le bulletin depuis l'archive.
8. Admin montre une entr�e `audit_log` (publication ou modification note).

---

## 7. Ordre de d�veloppement recommand�

1. `leyisa_mvp.sql` + migrations Doctrine  
2. Module 1 (auth + audit)  
3. Modules 2 + 3 (structure + inscriptions)  
4. Module 4 (enseignement + notes)  
5. Module 5 (publication + PDF + archive)  

**Phrase d'�quipe :**  
*On ne r�duit pas le projet. On code d'abord le noyau avec les m�mes noms, les m�mes r�gles, les m�mes tests.*

---

*Fin de l'annexe technique � � joindre au Guide MVP Backend LEYISA SCHOOL*
