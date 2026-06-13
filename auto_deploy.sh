#!/bin/bash

# =============================================================================
# auto_deploy.sh - Script d'automatisation du déploiement
# TP DevOps - UCAD Département Informatique 2025-2026
# =============================================================================

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# QUESTION 2 : Fonction de log avec horodatage
# =============================================================================
log() {
    local LEVEL="$1"
    local MESSAGE="$2"
    local TIMESTAMP
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    local LOG_FILE="deploy_$(date '+%Y%m%d').log"

    case "$LEVEL" in
        "INFO")  echo -e "${BLUE}[$TIMESTAMP] [INFO]${NC}  $MESSAGE" ;;
        "OK")    echo -e "${GREEN}[$TIMESTAMP] [OK]${NC}    $MESSAGE" ;;
        "WARN")  echo -e "${YELLOW}[$TIMESTAMP] [WARN]${NC}  $MESSAGE" ;;
        "ERROR") echo -e "${RED}[$TIMESTAMP] [ERROR]${NC} $MESSAGE" ;;
        *)       echo -e "[$TIMESTAMP] $MESSAGE" ;;
    esac

    # Sauvegarde du log dans un fichier (sans couleurs ANSI)
    echo "[$TIMESTAMP] [$LEVEL] $MESSAGE" >> "$LOG_FILE"
}

# =============================================================================
# Affichage de l'aide
# =============================================================================
usage() {
    echo ""
    echo "Usage: $0 [OPTIONS] <REPO_URL>"
    echo ""
    echo "Options:"
    echo "  -d, --dir       Nom du répertoire cible (défaut: mon_app)"
    echo "  -b, --branch    Branche à cloner (défaut: main)"
    echo "  -h, --help      Afficher cette aide"
    echo ""
    echo "Exemple:"
    echo "  $0 https://github.com/Lyfas1711/tp-devops-automatisation.git"
    echo "  $0 -d mon_projet -b develop https://github.com/Lyfas1711/tp-devops-automatisation.git"
    echo ""
}

# =============================================================================
# QUESTION 1 : Accepter l'URL du dépôt en paramètre
# =============================================================================
parse_args() {
    PROJECT_DIR="mon_app"
    BRANCH="main"
    REPO_URL=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dir)
                PROJECT_DIR="$2"
                shift 2
                ;;
            -b|--branch)
                BRANCH="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            http*|git*)
                REPO_URL="$1"
                shift
                ;;
            *)
                log "ERROR" "Argument inconnu: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Vérifier que l'URL est fournie
    if [ -z "$REPO_URL" ]; then
        log "ERROR" "URL du dépôt manquante."
        usage
        exit 1
    fi
}

# =============================================================================
# Vérification des dépendances
# =============================================================================
check_dependencies() {
    log "INFO" "Vérification des dépendances..."

    local DEPS=("git" "node" "npm")
    local MISSING=0

    for dep in "${DEPS[@]}"; do
        if command -v "$dep" > /dev/null 2>&1; then
            local VERSION
            VERSION=$("$dep" --version 2>/dev/null | head -1)
            log "OK" "$dep trouvé : $VERSION"
        else
            log "ERROR" "$dep requis mais non installé."
            MISSING=1
        fi
    done

    if [ "$MISSING" -eq 1 ]; then
        log "ERROR" "Des dépendances manquent. Abandon."
        exit 1
    fi

    log "OK" "Toutes les dépendances sont présentes."
}

# =============================================================================
# Clonage ou mise à jour du dépôt
# =============================================================================
clone_or_update() {
    log "INFO" "Préparation du dépôt..."

    if [ -d "$PROJECT_DIR" ]; then
        log "WARN" "Le répertoire $PROJECT_DIR existe déjà. Mise à jour..."
        cd "$PROJECT_DIR" || exit 1
        git pull origin "$BRANCH"
        if [ $? -ne 0 ]; then
            log "ERROR" "Échec de la mise à jour du dépôt."
            exit 1
        fi
        log "OK" "Dépôt mis à jour."
    else
        log "INFO" "Clonage du dépôt depuis $REPO_URL (branche: $BRANCH)..."
        git clone -b "$BRANCH" "$REPO_URL" "$PROJECT_DIR"
        if [ $? -ne 0 ]; then
            log "ERROR" "Échec du clonage du dépôt."
            exit 1
        fi
        cd "$PROJECT_DIR" || exit 1
        log "OK" "Dépôt cloné avec succès."
    fi
}

# =============================================================================
# Installation des dépendances Node.js
# =============================================================================
install_dependencies() {
    log "INFO" "Installation des dépendances npm..."
    npm install
    if [ $? -ne 0 ]; then
        log "ERROR" "Échec de l'installation des dépendances."
        exit 1
    fi
    log "OK" "Dépendances installées."
}

# =============================================================================
# Lancement des tests
# =============================================================================
run_tests() {
    log "INFO" "Lancement des tests unitaires..."
    npm test
    if [ $? -eq 0 ]; then
        log "OK" "Tous les tests sont passés."
        return 0
    else
        log "ERROR" "Échec des tests. Déploiement interrompu."
        return 1
    fi
}

# =============================================================================
# QUESTION 3 : Démarrer l'application en arrière-plan et sauvegarder le PID
# =============================================================================
start_application() {
    local PID_FILE="../deploy.pid"
    local LOG_APP="../app.log"

    # Vérifier si une instance tourne déjà
    if [ -f "$PID_FILE" ]; then
        local OLD_PID
        OLD_PID=$(cat "$PID_FILE")
        if kill -0 "$OLD_PID" 2>/dev/null; then
            log "WARN" "Une instance tourne déjà (PID: $OLD_PID). Arrêt..."
            kill "$OLD_PID"
            sleep 2
        fi
        rm -f "$PID_FILE"
    fi

    log "INFO" "Démarrage de l'application en arrière-plan..."

    # Lancer l'application en arrière-plan, rediriger les logs
    nohup npm start > "$LOG_APP" 2>&1 &

    local NEW_PID=$!
    echo "$NEW_PID" > "$PID_FILE"

    # Attendre un peu et vérifier que le processus tourne
    sleep 2
    if kill -0 "$NEW_PID" 2>/dev/null; then
        log "OK" "Application démarrée avec succès."
        log "OK" "PID: $NEW_PID (sauvegardé dans $PID_FILE)"
        log "OK" "Logs disponibles dans $LOG_APP"
    else
        log "ERROR" "L'application n'a pas démarré correctement."
        rm -f "$PID_FILE"
        exit 1
    fi
}

# =============================================================================
# SCRIPT PRINCIPAL
# =============================================================================
main() {
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}   DÉPLOIEMENT AUTOMATIQUE - TP DevOps     ${NC}"
    echo -e "${GREEN}   UCAD - Département Informatique 2025    ${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""

    # Parser les arguments (Question 1)
    parse_args "$@"

    log "INFO" "Démarrage du déploiement..."
    log "INFO" "Dépôt    : $REPO_URL"
    log "INFO" "Branche  : $BRANCH"
    log "INFO" "Dossier  : $PROJECT_DIR"

    # Étapes du déploiement
    check_dependencies
    clone_or_update
    install_dependencies

    if run_tests; then
        start_application  # Question 3 : lancement en arrière-plan
        echo ""
        log "OK" "=== DÉPLOIEMENT TERMINÉ AVEC SUCCÈS ==="
    else
        echo ""
        log "ERROR" "=== DÉPLOIEMENT ÉCHOUÉ (tests non passés) ==="
        exit 1
    fi
}

# Point d'entrée
main "$@"
