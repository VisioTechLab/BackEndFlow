<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Platforms\SQLitePlatform;
use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260312120000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Jour 1 : tables ecole et utilisateur (auth, roles, tenant)';
    }

    public function up(Schema $schema): void
    {
        if ($this->connection->getDatabasePlatform() instanceof SQLitePlatform) {
            $this->addSql('CREATE TABLE ecole (id_ecole INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, nom_ecole VARCHAR(150) NOT NULL, code_ecole VARCHAR(20) NOT NULL, province VARCHAR(80) DEFAULT NULL, commune VARCHAR(80) DEFAULT NULL, created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL)');
            $this->addSql('CREATE UNIQUE INDEX uk_ecole_code ON ecole (code_ecole)');
            $this->addSql('CREATE TABLE utilisateur (id_utilisateur INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, id_ecole INTEGER NOT NULL, nom_user VARCHAR(50) NOT NULL, postnom_user VARCHAR(50) NOT NULL, prenom_user VARCHAR(50) DEFAULT NULL, code_user VARCHAR(30) NOT NULL, email_user VARCHAR(100) NOT NULL, telephone VARCHAR(20) DEFAULT NULL, password_hash VARCHAR(255) NOT NULL, roles CLOB NOT NULL, is_active BOOLEAN DEFAULT 1 NOT NULL, created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL, CONSTRAINT FK_utilisateur_ecole FOREIGN KEY (id_ecole) REFERENCES ecole (id_ecole) NOT DEFERRABLE INITIALLY IMMEDIATE)');
            $this->addSql('CREATE INDEX IDX_utilisateur_ecole ON utilisateur (id_ecole)');
            $this->addSql('CREATE UNIQUE INDEX uk_utilisateur_ecole_code ON utilisateur (id_ecole, code_user)');
            $this->addSql('CREATE UNIQUE INDEX uk_utilisateur_ecole_email ON utilisateur (id_ecole, email_user)');

            return;
        }

        $this->addSql('CREATE TABLE ecole (id_ecole INT UNSIGNED AUTO_INCREMENT NOT NULL, nom_ecole VARCHAR(150) NOT NULL, code_ecole VARCHAR(20) NOT NULL, province VARCHAR(80) DEFAULT NULL, commune VARCHAR(80) DEFAULT NULL, created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL, UNIQUE INDEX uk_ecole_code (code_ecole), PRIMARY KEY (id_ecole)) DEFAULT CHARACTER SET utf8mb4 COLLATE `utf8mb4_unicode_ci` ENGINE = InnoDB');
        $this->addSql('CREATE TABLE utilisateur (id_utilisateur INT UNSIGNED AUTO_INCREMENT NOT NULL, id_ecole INT UNSIGNED NOT NULL, nom_user VARCHAR(50) NOT NULL, postnom_user VARCHAR(50) NOT NULL, prenom_user VARCHAR(50) DEFAULT NULL, code_user VARCHAR(30) NOT NULL, email_user VARCHAR(100) NOT NULL, telephone VARCHAR(20) DEFAULT NULL, password_hash VARCHAR(255) NOT NULL, roles JSON NOT NULL, is_active TINYINT(1) DEFAULT 1 NOT NULL, created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL, INDEX IDX_utilisateur_ecole (id_ecole), UNIQUE INDEX uk_utilisateur_ecole_code (id_ecole, code_user), UNIQUE INDEX uk_utilisateur_ecole_email (id_ecole, email_user), PRIMARY KEY (id_utilisateur)) DEFAULT CHARACTER SET utf8mb4 COLLATE `utf8mb4_unicode_ci` ENGINE = InnoDB');
        $this->addSql('ALTER TABLE utilisateur ADD CONSTRAINT FK_utilisateur_ecole FOREIGN KEY (id_ecole) REFERENCES ecole (id_ecole)');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP TABLE utilisateur');
        $this->addSql('DROP TABLE ecole');
    }
}
