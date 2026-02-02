# 1. Image de base officielle et légère
FROM python:3.9-slim

# 2. Bonnes pratiques : on évite les fichiers temporaires de pip
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Création d'un répertoire de travail
WORKDIR /app

# --- SECURITY FIX : Mise à jour système ---
# Indispensable pour que Trivy ne hurle pas sur des CVE Debian corrigées
RUN apt-get update && \ 
    apt-get upgrade -y && \ 
    rm -rf /var/lib/apt/lists/*

# 4. Installation des dépendances
# ⚠️ CORRECTION ICI : On suppose que requirements.txt est maintenant à la racine du projet
COPY requirements.txt .

# Update de pip pour la sécurité
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
# Installation des libs
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copie du code source
# On copie tout le contenu du dossier local 'app/' vers le dossier '/app' du conteneur
COPY app/ .

# 6. SECURITY : Création d'un utilisateur non-root
RUN useradd -r -u 1001 -g root appuser

# 7. Changement de propriétaire
RUN chown -R appuser:root /app

# 8. SECURITY : On bascule sur l'utilisateur non-root
USER 1001

# 9. Exposition du port
EXPOSE 8080

# 10. Lancement (Gunicorn va chercher 'main.py' qui est maintenant à la racine de /app)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--access-logfile", "-", "main:app"]