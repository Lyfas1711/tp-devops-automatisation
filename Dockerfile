# Dockerfile - TP DevOps UCAD 2025-2026
# Image de base légère Node.js
FROM node:18-alpine

# Métadonnées
LABEL maintainer="Étudiant UCAD"
LABEL description="Application TP DevOps - API Express"

# Créer le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances en premier (optimisation cache Docker)
COPY package*.json ./

# Installer uniquement les dépendances de production
RUN npm install --production

# Copier le reste du code source
COPY src/ ./src/

# Exposer le port de l'application
EXPOSE 3000

# Variable d'environnement
ENV NODE_ENV=production

# Commande de démarrage
CMD ["node", "src/app.js"]
