<?php

declare(strict_types=1);

namespace App\Shared\Enum;

enum UserRole: string
{
    case ADMIN = 'ROLE_ADMIN';
    case DIRECTION = 'ROLE_DIRECTION';
    case ENSEIGNANT = 'ROLE_ENSEIGNANT';
    case PARENT = 'ROLE_PARENT';
    case ELEVE = 'ROLE_ELEVE';
    case COMPTABLE = 'ROLE_COMPTABLE';
    case SURVEILLANT = 'ROLE_SURVEILLANT';

    /**
     * @return list<string>
     */
    public static function values(): array
    {
        return array_map(static fn (self $role): string => $role->value, self::cases());
    }
}
