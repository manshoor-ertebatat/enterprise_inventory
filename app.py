from flask import Flask
from app.models import db, User
from app.routes import bp

import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

app = Flask(
    __name__,
    template_folder=os.path.join(BASE_DIR, "app", "templates"),
    static_folder=os.path.join(BASE_DIR, "app", "static"),
    static_url_path="/static",
)
app.secret_key = "secret"

app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///data.db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)

with app.app_context():

    db.create_all()

    admin = User.query.filter_by(
        username="admin"
    ).first()

    if not admin:

        admin = User(
            username="admin",
            password="1234",
            role="admin"
        )

        db.session.add(admin)
        db.session.commit()

app.register_blueprint(bp)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
