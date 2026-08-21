from flask import Flask, jsonify

from app.config import Config
from app.extensions import db, login_manager, mail, migrate
from app.auth import auth_bp
from app import models
from app.models import User

def create_app(config_class=Config):
    app = Flask(__name__)

    app.config.from_object(config_class)

    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    mail.init_app(app)

    @login_manager.user_loader
    def load_user(user_id):
        return db.session.get(User, int(user_id))

    @login_manager.unauthorized_handler
    def unauthorized():
        return jsonify({
            "success": False,
            "message": "Authentication is required."
        }), 401

    app.register_blueprint(auth_bp)



    return app