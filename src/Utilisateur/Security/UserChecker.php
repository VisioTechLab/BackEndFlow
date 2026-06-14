<?php

declare(strict_types=1);

namespace App\Utilisateur\Security;

use App\Utilisateur\Entity\User;
use Symfony\Component\Security\Core\Exception\CustomUserMessageAccountStatusException;
use Symfony\Component\Security\Core\User\UserCheckerInterface;
use Symfony\Component\Security\Core\User\UserInterface;

final class UserChecker implements UserCheckerInterface
{
    public function checkPreAuth(UserInterface $user): void
    {
        if (!$user instanceof User) {
            return;
        }

        if (!$user->isActive()) {
            throw new CustomUserMessageAccountStatusException('Ce compte est desactive.');
        }
    }

    public function checkPostAuth(UserInterface $user): void
    {
    }
}
