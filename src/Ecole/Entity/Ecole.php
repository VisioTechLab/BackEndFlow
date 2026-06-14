<?php

declare(strict_types=1);

namespace App\Ecole\Entity;

use App\Utilisateur\Entity\User;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity]
#[ORM\Table(name: 'ecole')]
class Ecole
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(name: 'id_ecole')]
    private ?int $id = null;

    #[ORM\Column(name: 'nom_ecole', length: 150)]
    private string $nomEcole;

    #[ORM\Column(name: 'code_ecole', length: 20, unique: true)]
    private string $codeEcole;

    #[ORM\Column(length: 80, nullable: true)]
    private ?string $province = null;

    #[ORM\Column(length: 80, nullable: true)]
    private ?string $commune = null;

    /** @var Collection<int, User> */
    #[ORM\OneToMany(mappedBy: 'ecole', targetEntity: User::class)]
    private Collection $utilisateurs;

    #[ORM\Column(name: 'created_at')]
    private \DateTimeImmutable $createdAt;

    #[ORM\Column(name: 'updated_at')]
    private \DateTimeImmutable $updatedAt;

    public function __construct(string $nomEcole, string $codeEcole)
    {
        $this->nomEcole = $nomEcole;
        $this->codeEcole = $codeEcole;
        $this->utilisateurs = new ArrayCollection();
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getNomEcole(): string
    {
        return $this->nomEcole;
    }

    public function getCodeEcole(): string
    {
        return $this->codeEcole;
    }

    public function touchUpdatedAt(): void
    {
        $this->updatedAt = new \DateTimeImmutable();
    }
}
