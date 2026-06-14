<?php

declare(strict_types=1);

namespace App\Utilisateur\Repository;

use App\Ecole\Entity\Ecole;
use App\Utilisateur\Entity\User;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<User>
 */
class UserRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, User::class);
    }

    public function findOneByEmail(string $email): ?User
    {
        return $this->createQueryBuilder('u')
            ->andWhere('u.email = :email')
            ->setParameter('email', mb_strtolower(trim($email)))
            ->getQuery()
            ->getOneOrNullResult();
    }

    public function findOneByIdAndEcole(int $id, Ecole $ecole): ?User
    {
        return $this->createQueryBuilder('u')
            ->andWhere('u.id = :id')
            ->andWhere('u.ecole = :ecole')
            ->setParameter('id', $id)
            ->setParameter('ecole', $ecole)
            ->getQuery()
            ->getOneOrNullResult();
    }
}
