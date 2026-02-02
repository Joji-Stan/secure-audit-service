SECURE AUDIT SERVICE
================================================================================

DESCRIPTION
-----------
Secure Audit Service est une architecture de référence (Blueprint) démontrant
l'implémentation d'une chaîne DevSecOps complète. Ce projet déploie une API
RESTful Python (Flask) connectée à une base de données PostgreSQL, orchestrée
par Kubernetes et surveillée par une stack ELK.

L'objectif principal est d'illustrer l'approche "Shift-Left Security" en
intégrant des contrôles de sécurité automatisés (SAST, SCA) directement dans
le cycle d'intégration continue (CI).

STACK TECHNIQUE
---------------
- Application   : Python 3.9, Flask, SQLAlchemy, Gunicorn
- Base de Données : PostgreSQL 15 (StatefulSet)
- Orchestration : Kubernetes (Minikube), Docker
- Observabilité : Stack ELK (Elasticsearch, Filebeat, Kibana)
- CI/CD         : GitHub Actions
- Sécurité      : Bandit (SAST), Trivy (SCA)

FONCTIONNALITES DE SECURITE (HARDENING)
---------------------------------------
Ce projet met en œuvre plusieurs couches de sécurité défensive :

1. Analyse Statique (SAST) :
   Intégration de Bandit dans le pipeline CI pour détecter les faiblesses
   de code (ex: secrets en clair, interfaces d'écoute non sécurisées).

2. Analyse de Conteneurs (SCA) :
   Scan des images Docker via Trivy pour identifier les vulnérabilités
   connues (CVE) au niveau de l'OS (Debian) et des dépendances Python.

3. Durcissement des Conteneurs :
   Exécution des processus en tant qu'utilisateur non privilégié (UID 1001)
   pour prévenir l'escalade de privilèges (exécution Non-Root).

4. Gestion des Secrets :
   Utilisation exclusive de Kubernetes Secrets pour l'injection des
   identifiants de base de données. Aucune donnée sensible n'est stockée
   dans le code source ou les manifestes de déploiement.

5. Gestion des Risques (Risk Acceptance) :
   Procédure formelle d'acceptation des risques via fichiers d'exclusion
   documentés (.trivyignore) pour les vulnérabilités non patchables.

ARCHITECTURE DU PIPELINE CI/CD
------------------------------
Le workflow est automatisé via GitHub Actions et s'exécute à chaque modification
sur la branche principale (main) :

[Job 1] Securité du Code : Audit Bandit. Échec du pipeline en cas d'erreur.
[Job 2] Build & Scan : Construction de l'image Docker et validation Trivy.

INSTALLATION ET DEPLOIEMENT
---------------------------
Pré-requis : Docker Desktop, Minikube, Kubectl.

1. Démarrer l'environnement Kubernetes local :
   $ minikube start

2. Déployer l'infrastructure (Secrets, DB, API, ELK) :
   $ kubectl apply -f k8s/

3. Vérifier le statut des services :
   $ kubectl get pods

VERIFICATION ET TESTS
---------------------
L'API expose un endpoint d'audit qui persiste chaque visite en base de données.

1. Exposer le service sur le poste local :
   $ kubectl port-forward service/secure-api-service 8080:80

2. Tester la connectivité et la persistance :
   $ curl http://localhost:8080/

   Sortie attendue :
   {"message": "API Connectée à la BDD", "visites_totales": 1}

INFRASTRUCTURE AS CODE (TERRAFORM)
----------------------------------
Le projet inclut une configuration Terraform complète pour le déploiement sur AWS.
- Emplacement : dossier /terraform
- Cible : Cluster EKS (Elastic Kubernetes Service) + VPC sécurisé.
Note : Ce code sert de modèle de production (Blueprint). En local, le projet utilise Minikube.

CONTACT ET MAINTENANCE
----------------------
Dépôt : https://github.com/Joji-Stan/secure-audit-service
Statut du Build : Consulter l'onglet "Actions" du dépôt GitHub.