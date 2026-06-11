-- ============================================================================
-- NETTOYAGE ET SÉCURISATION DE L'ENVIRONNEMENT
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS recevoir_notif;
DROP TABLE IF EXISTS lien_parental;
DROP TABLE IF EXISTS suivre_presence;
DROP TABLE IF EXISTS avoir_note;
DROP TABLE IF EXISTS piloter_visibilite;
DROP TABLE IF EXISTS dispenser;
DROP TABLE IF EXISTS detail_archive_matiere;
DROP TABLE IF EXISTS archive;
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS inscription;
DROP TABLE IF EXISTS parent;
DROP TABLE IF EXISTS evaluation;
DROP TABLE IF EXISTS matiere;
DROP TABLE IF EXISTS eleve;
DROP TABLE IF EXISTS professeur;
DROP TABLE IF EXISTS classe;
DROP TABLE IF EXISTS user_;
DROP TABLE IF EXISTS ecole;
DROP TABLE IF EXISTS niveau_etude;
DROP TABLE IF EXISTS groupe_scolaire;
DROP TABLE IF EXISTS groupe_matiere;
DROP TABLE IF EXISTS periode;
DROP TABLE IF EXISTS option_etude;
DROP TABLE IF EXISTS prov_educ;
DROP TABLE IF EXISTS annee;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- 1. TABLES DE RÉFÉRENCE ET PARAMÉTRAGES GLOBAUX
-- ============================================================================

CREATE TABLE annee(
   id_annee INT AUTO_INCREMENT,
   libelle_annee VARCHAR(9) NOT NULL, -- Format '2025-2026'
   statut_annee VARCHAR(15) NOT NULL, -- 'OUVERTE', 'CLOTUREE'
   PRIMARY KEY(id_annee)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE prov_educ(
   id_prov_educ INT AUTO_INCREMENT,
   nom_prov_educ VARCHAR(50) NOT NULL,
   PRIMARY KEY(id_prov_educ)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE option_etude(
   id_option INT AUTO_INCREMENT,
   designation_opt VARCHAR(50) NOT NULL,
   section_option VARCHAR(50),
   PRIMARY KEY(id_option)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE periode(
   id_periode INT AUTO_INCREMENT,
   code_periode VARCHAR(10) NOT NULL, -- 'P1', 'P2', 'EXAM_S1'...
   type_periode VARCHAR(50) NOT NULL,  -- CORRECTION 3NF : Placé ici ('Journalière', 'Examen')
   PRIMARY KEY(id_periode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE groupe_matiere(
   id_groupe_mat INT AUTO_INCREMENT,
   max_periode INT NOT NULL,
   max_examen INT NOT NULL,
   PRIMARY KEY(id_groupe_mat)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE groupe_scolaire(
   id_groupe_scolaire INT AUTO_INCREMENT,
   nom_groupe VARCHAR(100) NOT NULL,
   PRIMARY KEY(id_groupe_scolaire)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE niveau_etude(
   id_niveau INT AUTO_INCREMENT,
   designation_niveau VARCHAR(50) NOT NULL, -- Ex: '3ème Humanités'
   PRIMARY KEY(id_niveau)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 2. STRUCTURES DE PARTITIONNEMENT ET COUCHE MULTI-TENANT (SaaS)
-- ============================================================================

CREATE TABLE ecole(
   id_ecole INT AUTO_INCREMENT,
   nom_ecole VARCHAR(150) NOT NULL,
   code_ecole VARCHAR(20) NOT NULL,
   type_ecole VARCHAR(20),
   commune_ecole VARCHAR(50),
   id_prov_educ INT NOT NULL,
   id_groupe_scolaire INT NOT NULL,
   PRIMARY KEY(id_ecole),
   UNIQUE KEY UNQ_code_ecole (code_ecole),
   CONSTRAINT FK_ecole_prov FOREIGN KEY(id_prov_educ) REFERENCES prov_educ(id_prov_educ),
   CONSTRAINT FK_ecole_groupe FOREIGN KEY(id_groupe_scolaire) REFERENCES groupe_scolaire(id_groupe_scolaire)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_(
   id_user INT AUTO_INCREMENT,
   nom_user VARCHAR(50) NOT NULL,
   postnom_user VARCHAR(50) NOT NULL,
   prenom_user VARCHAR(50),
   code_user VARCHAR(20) NOT NULL,
   email_user VARCHAR(100),
   password_hash VARCHAR(255) NOT NULL,
   role_user VARCHAR(20) NOT NULL,
   id_ecole INT NOT NULL, -- Pivot d'isolation de session
   PRIMARY KEY(id_user),
   UNIQUE KEY UNQ_code_user (code_user),
   CONSTRAINT FK_user_ecole FOREIGN KEY(id_ecole) REFERENCES ecole(id_ecole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE classe(
   id_classe INT AUTO_INCREMENT,
   lettre_classe VARCHAR(2) DEFAULT 'A',
   id_niveau INT NOT NULL,
   id_option INT NOT NULL,
   id_annee INT NOT NULL,
   id_ecole INT NOT NULL, -- Pivot d'isolation pédagogique
   PRIMARY KEY(id_classe),
   CONSTRAINT FK_classe_niveau FOREIGN KEY(id_niveau) REFERENCES niveau_etude(id_niveau),
   CONSTRAINT FK_classe_option FOREIGN KEY(id_option) REFERENCES option_etude(id_option),
   CONSTRAINT FK_classe_annee FOREIGN KEY(id_annee) REFERENCES annee(id_annee),
   CONSTRAINT FK_classe_ecole FOREIGN KEY(id_ecole) REFERENCES ecole(id_ecole)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 3. ACTEURS DU SYSTEME (STRATÉGIE D'HÉRITAGE D'ENTITÉS TECHNIQUE JOINED)
-- ============================================================================

CREATE TABLE professeur(
   id_prof INT AUTO_INCREMENT,
   matricule_prof VARCHAR(20),
   id_user INT NOT NULL,
   PRIMARY KEY(id_prof),
   UNIQUE KEY UNQ_prof_user (id_user),
   CONSTRAINT FK_prof_user FOREIGN KEY(id_user) REFERENCES user_(id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE eleve(
   id_eleve INT AUTO_INCREMENT,
   matricule_eleve VARCHAR(25), -- IDNAT National
   date_naiss_eleve DATE,
   genre_eleve VARCHAR(2),
   id_user INT NOT NULL,
   PRIMARY KEY(id_eleve),
   UNIQUE KEY UNQ_eleve_user (id_user),
   UNIQUE KEY UNQ_matricule_eleve (matricule_eleve), -- CORRECTION : Contrainte d'unicité nationale
   CONSTRAINT FK_eleve_user FOREIGN KEY(id_user) REFERENCES user_(id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE parent(
   id_parent INT AUTO_INCREMENT,
   tel_parent VARCHAR(15),
   id_user INT NOT NULL,
   PRIMARY KEY(id_parent),
   UNIQUE KEY UNQ_parent_user (id_user),
   CONSTRAINT FK_parent_user FOREIGN KEY(id_user) REFERENCES user_(id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- CORRECTION : Ajout de la clé primaire id_parent_eleve selon les lignes jaunes du DD
CREATE TABLE lien_parental(
   id_parent_eleve INT AUTO_INCREMENT,
   id_eleve INT NOT NULL,
   id_parent INT NOT NULL,
   lien_parente VARCHAR(50) NOT NULL, -- 'PERE', 'MERE', 'TUTEUR'
   PRIMARY KEY(id_parent_eleve),
   UNIQUE KEY UNQ_liaison_parent_eleve (id_eleve, id_parent),
   CONSTRAINT FK_lien_eleve FOREIGN KEY(id_eleve) REFERENCES eleve(id_eleve),
   CONSTRAINT FK_lien_parent FOREIGN KEY(id_parent) REFERENCES parent(id_parent)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 4. PÉDAGOGIE, ÉVALUATIONS ET NOTATIONS VIVANTES
-- ============================================================================

CREATE TABLE matiere(
   id_matiere INT AUTO_INCREMENT,
   designation_mat VARCHAR(100) NOT NULL,
   id_groupe_mat INT,
   PRIMARY KEY(id_matiere),
   CONSTRAINT FK_matiere_groupe FOREIGN KEY(id_groupe_mat) REFERENCES groupe_matiere(id_groupe_mat)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE evaluation(
   id_evaluation INT AUTO_INCREMENT,
   type_evaluation VARCHAR(20) NOT NULL, -- 'TP', 'INTERRO', 'DEVOIR'
   date_evaluation DATE NOT NULL,
   id_periode INT NOT NULL,
   id_matiere INT NOT NULL,
   PRIMARY KEY(id_evaluation),
   CONSTRAINT FK_eval_periode FOREIGN KEY(id_periode) REFERENCES periode(id_periode),
   CONSTRAINT FK_eval_matiere FOREIGN KEY(id_matiere) REFERENCES matiere(id_matiere)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inscription(
   id_inscrire INT AUTO_INCREMENT,
   decision_deliberation VARCHAR(15) DEFAULT 'EN_COURS', -- 'ADMIS', 'A_REPRENDRE'
   id_classe INT NOT NULL,
   id_eleve INT NOT NULL,
   PRIMARY KEY(id_inscrire),
   CONSTRAINT FK_insc_classe FOREIGN KEY(id_classe) REFERENCES classe(id_classe),
   CONSTRAINT FK_insc_eleve FOREIGN KEY(id_eleve) REFERENCES eleve(id_eleve)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 5. STOCKAGE ET ARCHIVES SCELLÉES POUR LES BULLETINS (HISTORIQUE INDÉLÉBILE)
-- ============================================================================

CREATE TABLE archive(
   id_archive INT AUTO_INCREMENT,
   tot_general_archive DECIMAL(6,2),
   pourcentage_archive DECIMAL(5,2),
   rang_archive INT,
   conduite_archive VARCHAR(20),
   application_archive VARCHAR(20),
   assiduite_archive INT,
   mention_archive VARCHAR(30),
   id_inscrire INT NOT NULL,
   PRIMARY KEY(id_archive),
   CONSTRAINT FK_archive_insc FOREIGN KEY(id_inscrire) REFERENCES inscription(id_inscrire)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE detail_archive_matiere(
   id_detail_archive INT AUTO_INCREMENT,
   note_p1 DECIMAL(5,2),
   note_p2 DECIMAL(5,2),
   note_examen_s1 DECIMAL(5,2),
   total_s1 DECIMAL(5,2),
   note_p3 DECIMAL(5,2),
   note_p4 DECIMAL(5,2),
   note_examen_s2 DECIMAL(5,2),
   total_s2 DECIMAL(5,2),
   total_gen DECIMAL(5,2),
   id_matiere INT NOT NULL,
   id_archive INT NOT NULL,
   PRIMARY KEY(id_detail_archive),
   CONSTRAINT FK_det_matiere FOREIGN KEY(id_matiere) REFERENCES matiere(id_matiere),
   CONSTRAINT FK_det_archive FOREIGN KEY(id_archive) REFERENCES archive(id_archive)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 6. COMMUNICATIONS ET ETANCHÉITÉ DES ALERTES
-- ============================================================================

CREATE TABLE notification(
   id_notification INT AUTO_INCREMENT,
   titre_notif VARCHAR(100) NOT NULL,
   contenu_notif TEXT NOT NULL,
   date_envoi_notif DATETIME NOT NULL,
   cible_notif VARCHAR(20) NOT NULL, -- 'GLOBAL', 'ECOLE', 'CLASSE'
   id_ecole INT,
   id_classe INT,
   PRIMARY KEY(id_notification),
   CONSTRAINT FK_notif_ecole FOREIGN KEY(id_ecole) REFERENCES ecole(id_ecole),
   CONSTRAINT FK_notif_classe FOREIGN KEY(id_classe) REFERENCES classe(id_classe)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 7. TABLES D'ASSOCIATIONS COMPOSITES (RELACHEMENT MERISIEN)
-- ============================================================================

CREATE TABLE dispenser(
   id_classe INT,
   id_prof INT,
   id_matiere INT,
   PRIMARY KEY(id_classe, id_prof, id_matiere),
   CONSTRAINT FK_disp_classe FOREIGN KEY(id_classe) REFERENCES classe(id_classe),
   CONSTRAINT FK_disp_prof FOREIGN KEY(id_prof) REFERENCES professeur(id_prof),
   CONSTRAINT FK_disp_mat FOREIGN KEY(id_matiere) REFERENCES matiere(id_matiere)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE piloter_visibilite(
   id_classe INT,
   id_periode INT,
   statut_publication VARCHAR(15) NOT NULL, -- 'BROUILLON', 'PUBLIE' (Ligne jaune n°5)
   PRIMARY KEY(id_classe, id_periode),
   CONSTRAINT FK_pilot_classe FOREIGN KEY(id_classe) REFERENCES classe(id_classe),
   CONSTRAINT FK_pilot_per FOREIGN KEY(id_periode) REFERENCES periode(id_periode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE avoir_note(
   id_eleve INT,
   id_evaluation INT,
   valeur_note DECIMAL(5,2) NOT NULL,
   autorisation_modif BOOLEAN DEFAULT FALSE,
   PRIMARY KEY(id_eleve, id_evaluation),
   CONSTRAINT FK_avoir_eleve FOREIGN KEY(id_eleve) REFERENCES eleve(id_eleve),
   CONSTRAINT FK_avoir_eval FOREIGN KEY(id_evaluation) REFERENCES evaluation(id_evaluation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE suivre_presence(
   id_annee INT,
   id_eleve INT,
   date_presence DATE,
   statut_presence VARCHAR(25) NOT NULL, -- 'PRESENT', 'ABSENT_J', 'ABSENT_NJ'
   PRIMARY KEY(id_annee, id_eleve, date_presence),
   CONSTRAINT FK_pres_annee FOREIGN KEY(id_annee) REFERENCES annee(id_annee),
   CONSTRAINT FK_pres_eleve FOREIGN KEY(id_eleve) REFERENCES eleve(id_eleve)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recevoir_notif(
   id_user INT,
   id_notification INT,
   statut_lecture BOOLEAN DEFAULT FALSE, -- Conservé uniquement ici pour la traçabilité multi-utilisateur
   PRIMARY KEY(id_user, id_notification),
   CONSTRAINT FK_rec_user FOREIGN KEY(id_user) REFERENCES user_(id_user),
   CONSTRAINT FK_rec_notif FOREIGN KEY(id_notification) REFERENCES notification(id_notification)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;