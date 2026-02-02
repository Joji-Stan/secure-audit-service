# 1. Image de base officielle et légère (Debian Slim vs Alpine pour compatibilité Python)
FROM python:3.9-slim

# 2. Bonnes pratiques : on évite les fichiers temporaires de pip
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Création d'un répertoire de travail
WORKDIR /app

# --- SECURITY FIX : Mise à jour système ---
# 1. On met à jour la liste des paquets (apt-get update)
# 2. On upgrade TOUS les paquets installés pour corriger les CVE (apt-get upgrade)
# 3. On nettoie le cache pour ne pas alourdir l'image 
RUN apt-get update && \ 
    apt-get upgrade -y && \ 
    rm -rf /var/lib/apt/lists/*

# 4. Installation des dépendances
# On copie juste le requirements d'abord pour profiter du cache Docker
COPY app/requirements.txt .
# --- SECURITY FIX : Update des outils Python ---
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN pip install --no-cache-dir -r requirements.txt

# 5. Copie du code source
COPY app/main.py .

# 6. SECURITY : Création d'un utilisateur non-root
# On crée un user 'appuser' sans mot de passe, sans home, juste pour exécuter l'application
RUN useradd -r -u 1001 -g root appuser

# 7. Changement de propriétaire des fichiers (pour que appuser puisse lire)
RUN chown -R appuser:root /app

# 8. SECURITY : On bascule sur l'utilisateur non-root
USER 1001

# 9. Exposition du port (Documentaire uniquement)
EXPOSE 8080

# 10. Lancement de l'application via Gunicorn (Serveur de prod, pas Flask dev server !)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers","2","--access-logfile","-", "main:app"]