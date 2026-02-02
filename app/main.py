from flask import Flask, jsonify, request, abort
from pythonjsonlogger import jsonlogger
import logging
import sys
import os
from flask_sqlalchemy import SQLAlchemy 
from sqlalchemy import text 

app = Flask(__name__)

# --- CONFIURATION LOGS ---
logger = logging.getLogger()
logHandler = logging.StreamHandler(sys.stdout)
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

# --- CONFIGURATION BDD ---
# On récupère les infos depuis les variables d'environnement (Sécurité !)
db_user = os.environ.get('DB_USER', 'appuser')
db_password = os.environ.get('DB_PASSWORD','password')
db_host = os.environ.get('DB_HOST','localhost')
db_name = os.environ.get('DB_NAME','secure_db')

app.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql://{db_user}:{db_password}@{db_host}:5432/{db_name}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Modèle de données (Table "Audit")
class AuditLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    message = db.Column(db.String(200), nullable=False)

# Création des tables au démarrage (pour le lab uniquement)
with app.app_context():
    try:
        db.create_all()
        logger.info({"event": "db_init", "status": "success"})
    except Exception as e:
        logger.error({"event": "db_init", "status": "failed", "error": str(e)})

@app.route('/')
def home():
    # On enregistre la visite dans la BDD
    try: 
        new_log = AuditLog(message="Visite sur l'accueil")
        db.session.add(new_log)
        db.session.commit()
        count = AuditLog.query.count()
        return jsonify({"message": "API Connectée à la BDD", "visites_totales": count})
    except Exception as e:
        return jsonify({"error": "Erreur BDD", "details": str(e)}), 500

@app.route('/health')
def health():
    return jsonify({"status": "up"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080) #nosec

