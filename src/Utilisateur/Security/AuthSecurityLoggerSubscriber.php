<?php

declare(strict_types=1);

namespace App\Utilisateur\Security;

use App\Utilisateur\Entity\User;
use Lexik\Bundle\JWTAuthenticationBundle\Event\JWTInvalidEvent;
use Lexik\Bundle\JWTAuthenticationBundle\Event\JWTNotFoundEvent;
use Lexik\Bundle\JWTAuthenticationBundle\Events;
use Psr\Log\LoggerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Security\Http\Event\LoginFailureEvent;
use Symfony\Component\Security\Http\Event\LoginSuccessEvent;

/**
 * Logs d'audit auth pour futur SIEM — jamais de password, token ou secret.
 */
final class AuthSecurityLoggerSubscriber implements EventSubscriberInterface
{
    private const INACTIVE_ACCOUNT_MESSAGE = 'Ce compte est desactive.';

    public function __construct(
        #[Autowire(service: 'monolog.logger.security_auth')]
        private readonly LoggerInterface $logger,
    ) {
    }

    public static function getSubscribedEvents(): array
    {
        return [
            LoginSuccessEvent::class => 'onLoginSuccess',
            LoginFailureEvent::class => 'onLoginFailure',
            Events::JWT_NOT_FOUND => 'onJwtNotFound',
            Events::JWT_INVALID => 'onJwtInvalid',
        ];
    }

    public function onLoginSuccess(LoginSuccessEvent $event): void
    {
        if ('login' !== $event->getFirewallName()) {
            return;
        }

        $user = $event->getUser();
        $email = $user instanceof User ? $this->maskEmail($user->getEmail()) : 'unknown';

        $this->logger->info('auth.login.success', $this->context($event->getRequest(), [
            'email' => $email,
            'roles' => $user->getRoles(),
        ]));
    }

    public function onLoginFailure(LoginFailureEvent $event): void
    {
        if ('/api/login' !== $event->getRequest()->getPathInfo()) {
            return;
        }

        $exception = $event->getException();
        $message = $exception->getMessage();
        $reason = self::INACTIVE_ACCOUNT_MESSAGE === $message
            ? 'inactive_account'
            : 'invalid_credentials';

        $this->logger->warning('auth.login.failure', $this->context($event->getRequest(), [
            'email' => $this->extractEmailFromRequest($event->getRequest()),
            'reason' => $reason,
        ]));
    }

    public function onJwtNotFound(JWTNotFoundEvent $event): void
    {
        $this->logger->warning('auth.jwt.missing', $this->context($event->getRequest(), [
            'path' => $event->getRequest()->getPathInfo(),
        ]));
    }

    public function onJwtInvalid(JWTInvalidEvent $event): void
    {
        $this->logger->warning('auth.jwt.invalid', $this->context($event->getRequest(), [
            'path' => $event->getRequest()->getPathInfo(),
        ]));
    }

    /**
     * @param array<string, mixed> $extra
     *
     * @return array<string, mixed>
     */
    private function context(Request $request, array $extra = []): array
    {
        return array_merge([
            'ip' => $request->getClientIp(),
            'method' => $request->getMethod(),
            'path' => $request->getPathInfo(),
            'user_agent' => $request->headers->get('User-Agent', 'unknown'),
        ], $extra);
    }

    private function extractEmailFromRequest(Request $request): ?string
    {
        if (!$request->isMethod('POST')) {
            return null;
        }

        $content = $request->getContent();
        if ('' === $content) {
            return null;
        }

        try {
            /** @var array<string, mixed> $data */
            $data = json_decode($content, true, 512, JSON_THROW_ON_ERROR);
            $email = $data['email'] ?? null;

            return \is_string($email) ? $this->maskEmail($email) : null;
        } catch (\JsonException) {
            return null;
        }
    }

    private function maskEmail(string $email): string
    {
        if (!str_contains($email, '@')) {
            return '***';
        }

        [$local, $domain] = explode('@', $email, 2);
        $masked = \strlen($local) > 2 ? substr($local, 0, 2).'***' : '***';

        return $masked.'@'.$domain;
    }
}
