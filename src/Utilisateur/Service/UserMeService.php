<?php

declare(strict_types=1);

namespace App\Utilisateur\Service;

use App\Utilisateur\Entity\User;

final class UserMeService
{
    /**
     * @return array<string, mixed>
     */
    public function buildProfile(User $user): array
    {
        return [
            'id' => $user->getId(),
            'nom' => $user->getNom(),
            'postnom' => $user->getPostnom(),
            'prenom' => $user->getPrenom(),
            'email' => $user->getEmail(),
            'telephone' => $user->getTelephone(),
            'roles' => array_values(array_filter(
                $user->getRoles(),
                static fn (string $role): bool => $role !== 'ROLE_USER'
            )),
            'isActive' => $user->isActive(),
            'idEcole' => $user->getIdEcole(),
            'createdAt' => $user->getCreatedAt()->format(\DateTimeInterface::ATOM),
        ];
    }
}
