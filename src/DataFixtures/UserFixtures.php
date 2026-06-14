<?php

declare(strict_types=1);

namespace App\DataFixtures;

use App\Ecole\Entity\Ecole;
use App\Shared\Enum\UserRole;
use App\Utilisateur\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

final class UserFixtures extends Fixture
{
    public function __construct(
        private readonly UserPasswordHasherInterface $passwordHasher,
    ) {
    }

    public function load(ObjectManager $manager): void
    {
        $ecole = new Ecole('Ecole Demo Leyisa', 'LEYISA-DEMO');
        $manager->persist($ecole);

        $accounts = [
            ['admin@leyisa.test', UserRole::ADMIN, 'ADMIN001', 'Admin', 'Systeme', 'Super'],
            ['direction@leyisa.test', UserRole::DIRECTION, 'DIR001', 'Marie', 'Kabongo', 'Claire'],
            ['enseignant@leyisa.test', UserRole::ENSEIGNANT, 'ENS001', 'Paul', 'Mputu', 'Jean'],
            ['parent@leyisa.test', UserRole::PARENT, 'PAR001', 'Grace', 'Ilunga', null],
            ['eleve@leyisa.test', UserRole::ELEVE, 'ELV001', 'Kevin', 'Mutombo', null],
            ['comptable@leyisa.test', UserRole::COMPTABLE, 'CPT001', 'Sarah', 'Ngoy', null],
            ['surveillant@leyisa.test', UserRole::SURVEILLANT, 'SRV001', 'Eric', 'Tshilombo', null],
        ];

        foreach ($accounts as [$email, $role, $code, $nom, $postnom, $prenom]) {
            $user = new User($ecole);
            $user
                ->setEmail($email)
                ->setCodeUser($code)
                ->setNom($nom)
                ->setPostnom($postnom)
                ->setPrenom($prenom)
                ->setRoles([$role->value])
                ->setPassword($this->passwordHasher->hashPassword($user, 'password123'));

            $manager->persist($user);
        }

        $manager->flush();
    }
}
