#!/bin/bash
set -e

echo "========================================"
echo "🚀 DÉMARRAGE DU PIPELINE DEVSECOPS"
echo "========================================"

# --- ETAPE 1 : SECURITE DU CODE (SAST) ---
echo ""
echo "🔍 [1/5] Analyse SAST (Bandit)"
# On installe bandit à la volée (ou on suppose qu'il est déjà là)
pip install bandit > /dev/null
# On scanne le dossier app/
# -ll : niveau de sévérité (Medium/High)
bandit -r app/ -ll
echo "✅ Code Python sécurisé."

# --- ETAPE 2 : LINTING ---
echo ""
echo "🔍 [2/5] Code Quality Check"
python3 -m py_compile app/main.py
echo "✅ Syntaxe valide."

# --- ETAPE 3 : BUILD DOCKER ---
echo ""
echo "🐳 [3/5] Build de l'image Docker"
docker build -t secure-api:pipeline .
echo "✅ Build terminé."

# --- ETAPE 4 : SCAN CONTENEUR (SCA) ---
echo ""
echo "🛡️  [4/5] Scan de vulnérabilités (Trivy)"
# On ignore les failles non fixables (Debian)
trivy image --exit-code 1 --severity CRITICAL,HIGH --ignore-unfixed secure-api:pipeline
echo "✅ Image Docker sécurisée."

# --- ETAPE 5 : DELIVERY ---
echo ""
echo "🚚 [5/5] Prêt pour le déploiement"
echo "✅ Pipeline Terminé avec Succès."