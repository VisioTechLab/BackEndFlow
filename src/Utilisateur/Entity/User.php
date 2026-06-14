<?php

declare(strict_types=1);

namespace App\Utilisateur\Entity;

use App\Ecole\Entity\Ecole;
use App\Utilisateur\Repository\UserRepository;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: 'utilisateur')]
#[ORM\UniqueConstraint(name: 'uk_utilisateur_ecole_code', columns: ['id_ecole', 'code_user'])]
#[ORM\UniqueConstraint(name: 'uk_utilisateur_ecole_email', columns: ['id_ecole', 'email_user'])]
#[ORM\HasLifecycleCallbacks]
class User implements UserInterface, PasswordAuthenticatedUserInterface
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(name: 'id_utilisateur')]
    #[Groups(['user:read'])]
    private ?int $id = null;

    #[ORM\ManyToOne(inversedBy: 'utilisateurs')]
    #[ORM\JoinColumn(name: 'id_ecole', referencedColumnName: 'id_ecole', nullable: false)]
    private Ecole $ecole;

    #[ORM\Column(name: 'nom_user', length: 50)]
    #[Assert\NotBlank]
    #[Groups(['user:read'])]
    private string $nom;

    #[ORM\Column(name: 'postnom_user', length: 50)]
    #[Assert\NotBlank]
    #[Groups(['user:read'])]
    private string $postnom;

    #[ORM\Column(name: 'prenom_user', length: 50, nullable: true)]
    #[Groups(['user:read'])]
    private ?string $prenom = null;

    #[ORM\Column(name: 'code_user', length: 30)]
    #[Assert\NotBlank]
    private string $codeUser;

    #[ORM\Column(name: 'email_user', length: 100)]
    #[Assert\NotBlank]
    #[Assert\Email]
    #[Groups(['user:read'])]
    private string $email;

    #[ORM\Column(length: 20, nullable: true)]
    #[Groups(['user:read'])]
    private ?string $telephone = null;

    #[ORM\Column(name: 'password_hash')]
    private string $password = '';

    /** @var list<string> */
    #[ORM\Column(type: Types::JSON)]
    #[Groups(['user:read'])]
    private array $roles = [];

    #[ORM\Column(name: 'is_active', options: ['default' => true])]
    #[Groups(['user:read'])]
    private bool $isActive = true;

    #[ORM\Column(name: 'created_at')]
    #[Groups(['user:read'])]
    private \DateTimeImmutable $createdAt;

    #[ORM\Column(name: 'updated_at')]
    private \DateTimeImmutable $updatedAt;

    public function __construct(Ecole $ecole)
    {
        $this->ecole = $ecole;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }

    #[ORM\PreUpdate]
    public function onPreUpdate(): void
    {
        $this->updatedAt = new \DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getEcole(): Ecole
    {
        return $this->ecole;
    }

    public function getIdEcole(): int
    {
        return $this->ecole->getId() ?? throw new \LogicException('Ecole sans identifiant.');
    }

    public function getNom(): string
    {
        return $this->nom;
    }

    public function setNom(string $nom): self
    {
        $this->nom = $nom;

        return $this;
    }

    public function getPostnom(): string
    {
        return $this->postnom;
    }

    public function setPostnom(string $postnom): self
    {
        $this->postnom = $postnom;

        return $this;
    }

    public function getPrenom(): ?string
    {
        return $this->prenom;
    }

    public function setPrenom(?string $prenom): self
    {
        $this->prenom = $prenom;

        return $this;
    }

    public function getCodeUser(): string
    {
        return $this->codeUser;
    }

    public function setCodeUser(string $codeUser): self
    {
        $this->codeUser = $codeUser;

        return $this;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function setEmail(string $email): self
    {
        $this->email = mb_strtolower(trim($email));

        return $this;
    }

    public function getTelephone(): ?string
    {
        return $this->telephone;
    }

    public function setTelephone(?string $telephone): self
    {
        $this->telephone = $telephone;

        return $this;
    }

    public function getPassword(): string
    {
        return $this->password;
    }

    public function setPassword(string $hashedPassword): self
    {
        $this->password = $hashedPassword;

        return $this;
    }

    /** @param list<string> $roles */
    public function setRoles(array $roles): self
    {
        $this->roles = array_values(array_unique($roles));

        return $this;
    }

    public function isActive(): bool
    {
        return $this->isActive;
    }

    public function setIsActive(bool $isActive): self
    {
        $this->isActive = $isActive;

        return $this;
    }

    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }

    public function getUserIdentifier(): string
    {
        return $this->email;
    }

    /** @return list<string> */
    public function getRoles(): array
    {
        $roles = $this->roles;
        $roles[] = 'ROLE_USER';

        return array_values(array_unique($roles));
    }

    public function eraseCredentials(): void
    {
    }
}
