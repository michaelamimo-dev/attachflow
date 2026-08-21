from app.extensions import db


class PasswordResetToken(db.Model):
    __tablename__ = "password_reset_tokens"

    id = db.Column(db.Integer, primary_key=True)

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    token_hash = db.Column(
        db.String(255),
        nullable=False,
        unique=True,
    )

    expires_at = db.Column(
        db.DateTime,
        nullable=False,
    )

    used_at = db.Column(
        db.DateTime,
        nullable=True,
    )

    created_at = db.Column(
        db.DateTime,
        server_default=db.func.current_timestamp(),
    )

    def __repr__(self):
        return f"<PasswordResetToken {self.id}>"