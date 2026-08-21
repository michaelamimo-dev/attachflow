from datetime import datetime

from flask_login import UserMixin

from app.extensions import db


class User(UserMixin, db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    university_id = db.Column(
        db.Integer,
        db.ForeignKey("universities.id"),
        nullable=False
    )

    first_name = db.Column(db.String(100), nullable=False)
    last_name = db.Column(db.String(100), nullable=False)

    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

    student_registration_number = db.Column(
        db.String(100),
        unique=True,
        nullable=False
    )

    phone_number = db.Column(db.String(30))
    profile_picture = db.Column(db.String(500))

    gender = db.Column(
        db.Enum(
            "Male",
            "Female",
            "Other",
            "Prefer not to say"
        )
    )

    date_of_birth = db.Column(db.Date)
    course = db.Column(db.String(255))
    year_of_study = db.Column(db.String(50))

    role = db.Column(
        db.Enum(
            "Student",
            "Supervisor",
            "Administrator"
        ),
        nullable=False,
        default="Student"
    )

    email_verified = db.Column(
        db.Boolean,
        nullable=False,
        default=False
    )

    email_verified_at = db.Column(db.DateTime)

    is_active = db.Column(
        db.Boolean,
        nullable=False,
        default=True
    )

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
        return f"<User {self.email}>"