from datetime import datetime

from app.extensions import db


class University(db.Model):
    __tablename__ = "universities"

    id = db.Column(db.Integer, primary_key=True)

    name = db.Column(db.String(255), unique=True, nullable=False)
    abbreviation = db.Column(db.String(50))
    country = db.Column(db.String(100))
    website = db.Column(db.String(255))

    created_at = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )

    updated_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow
    )

    deleted_at = db.Column(db.DateTime)

    def __repr__(self):
        return f"<University {self.name}>"