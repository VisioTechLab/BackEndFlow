-- ============================================================================
-- LEYISA SCHOOL - Schema MVP MySQL 8 / InnoDB
-- Version : architecture officielle validee, pret pour migrations
-- Tenant : ecole = client SaaS
-- Coherence tenant : TenantContext + TenantCoherenceValidator (pas de triggers SQL)
-- ============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS bulletin_archive_ligne;
DROP TABLE IF EXISTS bulletin_archive;
DROP TABLE IF EXISTS publication_periode;
DROP TABLE IF EXISTS note;
DROP TABLE IF EXISTS evaluation;
DROP TABLE IF EXISTS enseignement;
DROP TABLE IF EXISTS periode;
DROP TABLE IF EXISTS matiere;
DROP TABLE IF EXISTS inscription;
DROP TABLE IF EXISTS eleve;
DROP TABLE IF EXISTS classe;
DROP TABLE IF EXISTS annee_scolaire;
DROP TABLE IF EXISTS professeur;
DROP TABLE IF EXISTS utilisateur;
DROP TABLE IF EXISTS ecole;

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- TENANT
-- ----------------------------------------------------------------------------

CREATE TABLE ecole (
    id_ecole        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom_ecole       VARCHAR(150) NOT NULL,
    code_ecole      VARCHAR(20)  NOT NULL,
    province        VARCHAR(80)  NULL,
    commune         VARCHAR(80)  NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_ecole_code (code_ecole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- SOCLE - UTILISATEURS
-- ----------------------------------------------------------------------------

CREATE TABLE utilisateur (
    id_utilisateur  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    nom_user        VARCHAR(50)  NOT NULL,
    postnom_user    VARCHAR(50)  NOT NULL,
    prenom_user     VARCHAR(50)  NULL,
    code_user       VARCHAR(30)  NOT NULL,
    email_user      VARCHAR(100) NULL,
    password_hash   VARCHAR(255) NOT NULL,
    role_user       ENUM('ADMIN_ECOLE', 'PROFESSEUR') NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_utilisateur_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    UNIQUE KEY uk_utilisateur_ecole_code (id_ecole, code_user),
    UNIQUE KEY uk_utilisateur_ecole_email (id_ecole, email_user),
    INDEX idx_utilisateur_ecole (id_ecole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE professeur (
    id_prof         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_utilisateur  INT UNSIGNED NOT NULL,
    matricule_prof  VARCHAR(30)  NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_professeur_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_professeur_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur),
    UNIQUE KEY uk_professeur_utilisateur (id_utilisateur),
    UNIQUE KEY uk_professeur_ecole_matricule (id_ecole, matricule_prof),
    INDEX idx_professeur_ecole (id_ecole),
    INDEX idx_professeur_utilisateur (id_utilisateur)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- SCOLARITE - AnneeScolaire, Classe, Eleve, Inscription
-- ----------------------------------------------------------------------------

CREATE TABLE annee_scolaire (
    id_annee        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    libelle_annee   VARCHAR(9)   NOT NULL,
    statut_annee    ENUM('OUVERTE', 'CLOTUREE') NOT NULL DEFAULT 'OUVERTE',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_annee_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    UNIQUE KEY uk_annee_ecole_libelle (id_ecole, libelle_annee),
    INDEX idx_annee_ecole (id_ecole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE classe (
    id_classe       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_annee        INT UNSIGNED NOT NULL,
    niveau_classe   VARCHAR(20)  NOT NULL,
    option_classe   VARCHAR(50)  NOT NULL DEFAULT 'GENERALE',
    lettre_classe   VARCHAR(5)   NOT NULL DEFAULT 'A',
    designation     VARCHAR(100) NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_classe_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_classe_annee FOREIGN KEY (id_annee) REFERENCES annee_scolaire(id_annee),
    UNIQUE KEY uk_classe_ecole_annee_niveau_option_lettre (id_ecole, id_annee, niveau_classe, option_classe, lettre_classe),
    INDEX idx_classe_ecole (id_ecole),
    INDEX idx_classe_annee (id_annee),
    INDEX idx_classe_ecole_annee (id_ecole, id_annee)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE eleve (
    id_eleve        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    matricule_eleve VARCHAR(30)  NOT NULL,
    nom_eleve       VARCHAR(50)  NOT NULL,
    postnom_eleve   VARCHAR(50)  NOT NULL,
    prenom_eleve    VARCHAR(50)  NULL,
    genre_eleve     ENUM('M', 'F') NULL,
    date_naiss_eleve DATE NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_eleve_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    UNIQUE KEY uk_eleve_ecole_matricule (id_ecole, matricule_eleve),
    INDEX idx_eleve_ecole (id_ecole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inscription (
    id_inscription  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_eleve        INT UNSIGNED NOT NULL,
    id_classe       INT UNSIGNED NOT NULL,
    id_annee        INT UNSIGNED NOT NULL,
    date_inscription DATE NOT NULL,
    decision_deliberation VARCHAR(20) NULL DEFAULT 'EN_COURS',
    statut_inscription ENUM('EN_COURS', 'VALIDEE', 'ANNULEE') NOT NULL DEFAULT 'EN_COURS',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inscription_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_inscription_eleve FOREIGN KEY (id_eleve) REFERENCES eleve(id_eleve),
    CONSTRAINT fk_inscription_classe FOREIGN KEY (id_classe) REFERENCES classe(id_classe),
    CONSTRAINT fk_inscription_annee FOREIGN KEY (id_annee) REFERENCES annee_scolaire(id_annee),
    UNIQUE KEY uk_inscription_eleve_annee (id_eleve, id_annee),
    INDEX idx_inscription_ecole (id_ecole),
    INDEX idx_inscription_classe (id_classe),
    INDEX idx_inscription_annee (id_annee),
    INDEX idx_inscription_eleve (id_eleve),
    INDEX idx_inscription_ecole_annee (id_ecole, id_annee)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- PEDAGOGIE - Matiere, Periode, Enseignement, Evaluation, Note
-- ----------------------------------------------------------------------------

CREATE TABLE matiere (
    id_matiere      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    designation     VARCHAR(100) NOT NULL,
    max_periode     DECIMAL(5,2) NOT NULL DEFAULT 0,
    max_examen      DECIMAL(5,2) NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_matiere_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    UNIQUE KEY uk_matiere_ecole_designation (id_ecole, designation),
    INDEX idx_matiere_ecole (id_ecole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE periode (
    id_periode      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    code_periode    VARCHAR(15)  NOT NULL,
    type_periode    VARCHAR(30)  NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_periode_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    UNIQUE KEY uk_periode_ecole_code (id_ecole, code_periode),
    INDEX idx_periode_ecole (id_ecole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE enseignement (
    id_enseignement INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_prof         INT UNSIGNED NOT NULL,
    id_matiere      INT UNSIGNED NOT NULL,
    id_classe       INT UNSIGNED NOT NULL,
    id_annee        INT UNSIGNED NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_enseignement_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_enseignement_prof FOREIGN KEY (id_prof) REFERENCES professeur(id_prof),
    CONSTRAINT fk_enseignement_matiere FOREIGN KEY (id_matiere) REFERENCES matiere(id_matiere),
    CONSTRAINT fk_enseignement_classe FOREIGN KEY (id_classe) REFERENCES classe(id_classe),
    CONSTRAINT fk_enseignement_annee FOREIGN KEY (id_annee) REFERENCES annee_scolaire(id_annee),
    UNIQUE KEY uk_enseignement_quad (id_prof, id_matiere, id_classe, id_annee),
    INDEX idx_enseignement_ecole (id_ecole),
    INDEX idx_enseignement_prof (id_prof),
    INDEX idx_enseignement_matiere (id_matiere),
    INDEX idx_enseignement_classe (id_classe),
    INDEX idx_enseignement_annee (id_annee)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE evaluation (
    id_evaluation   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_enseignement INT UNSIGNED NOT NULL,
    id_periode      INT UNSIGNED NOT NULL,
    type_evaluation VARCHAR(30)  NOT NULL,
    date_evaluation DATE         NOT NULL,
    bareme          DECIMAL(5,2) NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_evaluation_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_evaluation_enseignement FOREIGN KEY (id_enseignement) REFERENCES enseignement(id_enseignement),
    CONSTRAINT fk_evaluation_periode FOREIGN KEY (id_periode) REFERENCES periode(id_periode),
    INDEX idx_evaluation_ecole (id_ecole),
    INDEX idx_evaluation_enseignement (id_enseignement),
    INDEX idx_evaluation_periode (id_periode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE note (
    id_note         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_eleve        INT UNSIGNED NOT NULL,
    id_evaluation   INT UNSIGNED NOT NULL,
    valeur_note     DECIMAL(5,2) NOT NULL,
    autorisation_modif TINYINT(1) NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_note_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_note_eleve FOREIGN KEY (id_eleve) REFERENCES eleve(id_eleve),
    CONSTRAINT fk_note_evaluation FOREIGN KEY (id_evaluation) REFERENCES evaluation(id_evaluation),
    UNIQUE KEY uk_note_eleve_evaluation (id_eleve, id_evaluation),
    INDEX idx_note_ecole (id_ecole),
    INDEX idx_note_eleve (id_eleve),
    INDEX idx_note_evaluation (id_evaluation),
    INDEX idx_note_ecole_eleve (id_ecole, id_eleve)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- PUBLICATION & ARCHIVES EPST
-- ----------------------------------------------------------------------------

CREATE TABLE publication_periode (
    id_publication  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_classe       INT UNSIGNED NOT NULL,
    id_periode      INT UNSIGNED NOT NULL,
    statut_publication ENUM('BROUILLON', 'PUBLIE') NOT NULL DEFAULT 'BROUILLON',
    published_at    DATETIME NULL,
    published_by    INT UNSIGNED NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_publication_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_publication_classe FOREIGN KEY (id_classe) REFERENCES classe(id_classe),
    CONSTRAINT fk_publication_periode FOREIGN KEY (id_periode) REFERENCES periode(id_periode),
    CONSTRAINT fk_publication_user FOREIGN KEY (published_by) REFERENCES utilisateur(id_utilisateur),
    UNIQUE KEY uk_publication_classe_periode (id_classe, id_periode),
    INDEX idx_publication_ecole (id_ecole),
    INDEX idx_publication_classe (id_classe),
    INDEX idx_publication_periode (id_periode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bulletin_archive (
    id_bulletin_archive INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_inscription  INT UNSIGNED NOT NULL,
    type_bulletin   ENUM('S1', 'S2', 'ANNUEL') NOT NULL,
    total_general   DECIMAL(8,2) NULL,
    pourcentage     DECIMAL(5,2) NULL,
    rang            INT UNSIGNED NULL,
    conduite        VARCHAR(30) NULL,
    application     VARCHAR(30) NULL,
    assiduite       INT NULL,
    mention         VARCHAR(50) NULL,
    chemin_pdf      VARCHAR(255) NOT NULL,
    hash_pdf        CHAR(64)     NOT NULL,
    published_at    DATETIME NOT NULL,
    published_by    INT UNSIGNED NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bulletin_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_bulletin_inscription FOREIGN KEY (id_inscription) REFERENCES inscription(id_inscription),
    CONSTRAINT fk_bulletin_user FOREIGN KEY (published_by) REFERENCES utilisateur(id_utilisateur),
    UNIQUE KEY uk_bulletin_inscription_type (id_inscription, type_bulletin),
    INDEX idx_bulletin_ecole (id_ecole),
    INDEX idx_bulletin_inscription (id_inscription),
    INDEX idx_bulletin_type (type_bulletin),
    INDEX idx_bulletin_hash (hash_pdf)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bulletin_archive_ligne (
    id_ligne        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_bulletin_archive INT UNSIGNED NOT NULL,
    id_matiere      INT UNSIGNED NOT NULL,
    note_p1         DECIMAL(5,2) NULL,
    note_p2         DECIMAL(5,2) NULL,
    note_examen_s1  DECIMAL(5,2) NULL,
    total_s1        DECIMAL(5,2) NULL,
    note_p3         DECIMAL(5,2) NULL,
    note_p4         DECIMAL(5,2) NULL,
    note_examen_s2  DECIMAL(5,2) NULL,
    total_s2        DECIMAL(5,2) NULL,
    total_gen       DECIMAL(5,2) NULL,
    CONSTRAINT fk_ligne_bulletin FOREIGN KEY (id_bulletin_archive) REFERENCES bulletin_archive(id_bulletin_archive),
    CONSTRAINT fk_ligne_matiere FOREIGN KEY (id_matiere) REFERENCES matiere(id_matiere),
    UNIQUE KEY uk_ligne_bulletin_matiere (id_bulletin_archive, id_matiere),
    INDEX idx_ligne_matiere (id_matiere)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- AUDIT
-- ----------------------------------------------------------------------------

CREATE TABLE audit_log (
    id_audit        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_ecole        INT UNSIGNED NOT NULL,
    id_utilisateur  INT UNSIGNED NULL,
    action          VARCHAR(50)  NOT NULL,
    entite          VARCHAR(50)  NOT NULL,
    entite_id       INT UNSIGNED NOT NULL,
    ancienne_valeur JSON NULL,
    nouvelle_valeur JSON NULL,
    ip_adresse      VARCHAR(45)  NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_ecole FOREIGN KEY (id_ecole) REFERENCES ecole(id_ecole),
    CONSTRAINT fk_audit_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur),
    INDEX idx_audit_ecole (id_ecole),
    INDEX idx_audit_created (created_at),
    INDEX idx_audit_utilisateur (id_utilisateur),
    INDEX idx_audit_entite (entite, entite_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed periodes EPST : cree par ecole via PeriodeSeedService a la creation du tenant
-- Codes : P1, P2, EXAM_S1, P3, P4, EXAM_S2
