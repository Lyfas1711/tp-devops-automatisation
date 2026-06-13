<<<<<<< HEAD
# TP DevOps - Automatisation
**UCAD - Département Informatique - 2025-2026**

## Structure du projet

```
tp-devops-automatisation/
├── .github/
│   └── workflows/
│       └── ci.yml              # Pipeline GitHub Actions CI/CD
├── src/
│   └── app.js                  # Application Express (API ping/pong)
├── tests/
│   └── app.test.js             # Tests unitaires Jest
├── terraform/
│   └── main.tf                 # Infrastructure as Code (AWS EC2)
├── auto_deploy.sh              # Script bash d'automatisation
├── Dockerfile                  # Image Docker
├── package.json
├── .gitignore
└── README.md
```

---

## Partie 1 : Script Bash

### Exécuter le script

```bash
# Rendre le script exécutable
chmod +x auto_deploy.sh

# Utilisation de base (URL en paramètre)
./auto_deploy.sh https://github.com/Lyfas1711/tp-devops-automatisation.git

# Avec options
./auto_deploy.sh -d mon_projet -b develop https://github.com/Lyfas1711/tp-devops-automatisation.git
```

### Options disponibles


| `-d, --dir` | Nom du dossier cible | `mon_app` |
| `-b, --branch` | Branche Git | `main` |
| `-h, --help` | Afficher l'aide | - |

---

## Partie 2 : Application Node.js

### Installation locale

```bash
npm install
```

### Lancer les tests

```bash
npm test
```

### Démarrer l'application

```bash
npm start
# L'application tourne sur http://localhost:3000
```

### Routes API

| `/` | GET | Message de bienvenue |
| `/ping` | GET | `{"response": "pong"}` |
| `/status` | GET | Statut et uptime du serveur |

---

## Partie 3 : GitHub Actions

Le fichier `.github/workflows/ci.yml` définit un pipeline avec 3 jobs :

1. **build-and-test** : tests automatiques à chaque push/PR
2. **docker** : build et push vers Docker Hub (uniquement si tests passent)
3. **deploy** : déploiement SSH sur serveur (uniquement si tests passent)

### Secrets à configurer dans GitHub

```
Settings > Secrets and variables > Actions > New repository secret
```

| `DOCKER_USERNAME` | Nom d'utilisateur Docker Hub |
| `DOCKER_PASSWORD` | Mot de passe Docker Hub |
| `SSH_HOST` | Adresse IP du serveur |
| `SSH_USERNAME` | Utilisateur SSH |
| `SSH_PRIVATE_KEY` | Clé SSH privée |

---

## Partie 4 : Docker

### Build de l'image

```bash
docker build -t tp-devops-app .
```

### Lancer le conteneur

```bash
docker run -p 3000:3000 tp-devops-app
```

---

## Partie 5 : Terraform (Infrastructure AWS)

```bash
cd terraform/

# Initialiser Terraform
terraform init

# Voir les changements prévus
terraform plan

# Appliquer l'infrastructure
terraform apply -auto-approve

# Détruire l'infrastructure
terraform destroy
```

> **Prérequis** : Configurer les variables d'environnement AWS :
> ```bash
> export AWS_ACCESS_KEY_ID="votre-access-key"
> export AWS_SECRET_ACCESS_KEY="votre-secret-key"
> ```
