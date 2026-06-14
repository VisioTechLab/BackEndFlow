<?php

declare(strict_types=1);

namespace App\Utilisateur\Controller;

use App\Utilisateur\Entity\User;
use App\Utilisateur\Service\UserMeService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/api')]
final class UserMeController extends AbstractController
{
    public function __construct(
        private readonly UserMeService $userMeService,
    ) {
    }

    #[Route('/me', name: 'api_me', methods: ['GET'])]
    #[IsGranted('ROLE_USER')]
    public function __invoke(): JsonResponse
    {
        $user = $this->getUser();

        if (!$user instanceof User) {
            return $this->json(['message' => 'Utilisateur non authentifie.'], JsonResponse::HTTP_UNAUTHORIZED);
        }

        return $this->json($this->userMeService->buildProfile($user));
    }
}
