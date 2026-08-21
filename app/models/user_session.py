from app.extensions import db


class UserSession(db.Model):
    __tablename__ = "user_sessions"

    id = db.Column(db.Integer, primary_key=True)

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False,
    )

    session_token = db.Column(
        db.String(255),
        nullable=False,
        unique=True,
    )

    ip_address = db.Column(
        db.String(45),
        nullable=True,
    )

    user_agent = db.Column(
        db.Text,
        nullable=True,
    )

    remember_me = db.Column(
        db.Boolean,
        nullable=True,
        default=False,
    )

    last_activity = db.Column(
        db.DateTime,
        nullable=False,
    )

    expires_at = db.Column(
        db.DateTime,
        nullable=False,
    )

    created_at = db.Column(
        db.DateTime,
        server_default=db.func.current_timestamp(),
    )

    def __repr__(self):
        return f"<UserSession {self.id}>"