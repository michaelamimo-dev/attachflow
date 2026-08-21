import hashlib
import secrets
from datetime import datetime, timedelta, timezone

from flask import request, session
from flask_mail import Message
from flask_login import current_user, login_user, logout_user
from werkzeug.security import check_password_hash, generate_password_hash

from app.extensions import db, mail
from app.models import University, User
from app.models.email_verification_token import EmailVerificationToken
from app.models.user_session import UserSession


EMAIL_VERIFICATION_TOKEN_EXPIRY_HOURS = 24
SESSION_EXPIRY_HOURS = 24
REMEMBER_ME_EXPIRY_DAYS = 30


def _hash_token(token):
    """Return a SHA-256 hash of a raw token."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


# ==========================================================
# EMAIL VERIFICATION
# ==========================================================

def generate_email_verification_token():
    """
    Generate a cryptographically secure verification token.

    Returns:
        tuple:
            (raw_token, token_hash)

    The raw token is intended for delivery to the user.
    Only the token hash is stored in the database.
    """
    raw_token = secrets.token_urlsafe(32)
    token_hash = _hash_token(raw_token)

    return raw_token, token_hash


def register_user(data):
    """
    Create a new AttachFlow user account and its initial
    email verification token.

    Returns:
        tuple:
            (user, raw_verification_token)
        or
            (None, error_response)
    """

    email = data["email"].strip().lower()

    registration_number = data[
        "student_registration_number"
    ].strip()

    university_name = data["university"].strip()

    # --------------------------------------------------
    # Duplicate email check
    # --------------------------------------------------

    existing_email = User.query.filter_by(
        email=email
    ).first()

    if existing_email:
        return None, {
            "type": "duplicate",
            "message": (
                "An account with this information already exists."
            ),
        }

    # --------------------------------------------------
    # Duplicate student registration number check
    # --------------------------------------------------

    existing_registration = User.query.filter_by(
        student_registration_number=registration_number
    ).first()

    if existing_registration:
        return None, {
            "type": "duplicate",
            "message": (
                "An account with this information already exists."
            ),
        }

    # --------------------------------------------------
    # University lookup
    # --------------------------------------------------

    university = University.query.filter(
        db.func.lower(University.name) == university_name.lower(),
        University.deleted_at.is_(None),
    ).first()

    if university is None:
        return None, {
            "type": "validation",
            "field": "university",
            "message": (
                "The selected university does not exist."
            ),
        }

    # --------------------------------------------------
    # Password hashing
    # --------------------------------------------------

    password_hash = generate_password_hash(
        data["password"]
    )

    # --------------------------------------------------
    # Create user
    # --------------------------------------------------

    user = User(
        university_id=university.id,
        first_name=data["first_name"].strip(),
        last_name=data["last_name"].strip(),
        email=email,
        password_hash=password_hash,
        student_registration_number=registration_number,
        role="Student",
        email_verified=False,
        is_active=True,
    )

    db.session.add(user)

    # Flush gives us the generated user ID without
    # committing the transaction yet.
    db.session.flush()

    # --------------------------------------------------
    # Generate email verification token
    # --------------------------------------------------

    raw_token, token_hash = generate_email_verification_token()

    expires_at = (
        datetime.now(timezone.utc).replace(tzinfo=None)
        + timedelta(
            hours=EMAIL_VERIFICATION_TOKEN_EXPIRY_HOURS
        )
    )

    verification_token = EmailVerificationToken(
        user_id=user.id,
        token_hash=token_hash,
        expires_at=expires_at,
    )

    db.session.add(verification_token)

    # Commit user and verification token together.
    db.session.commit()

    return user, raw_token


def create_email_verification_token(user):
    """
    Create and persist a new email verification token
    for an existing user.

    Returns:
        raw_token
    """

    raw_token, token_hash = generate_email_verification_token()

    expires_at = (
        datetime.now(timezone.utc).replace(tzinfo=None)
        + timedelta(
            hours=EMAIL_VERIFICATION_TOKEN_EXPIRY_HOURS
        )
    )

    token = EmailVerificationToken(
        user_id=user.id,
        token_hash=token_hash,
        expires_at=expires_at,
    )

    db.session.add(token)
    db.session.commit()

    return raw_token


def send_verification_email(user, raw_token):
    """
    Send the email verification message containing
    the raw verification token.
    """

    verification_url = (
        "http://127.0.0.1:5000/api/v1/auth/verify-email"
        f"?token={raw_token}"
    )

    message = Message(
        subject="Verify your AttachFlow email address",
        recipients=[user.email],
        body=(
            f"Hello {user.first_name},\n\n"
            "Thank you for creating your AttachFlow account.\n\n"
            "Please verify your email address using the "
            "verification token below:\n\n"
            f"{raw_token}\n\n"
            "Verification endpoint:\n"
            f"{verification_url}\n\n"
            "This verification token expires in 24 hours.\n\n"
            "If you did not create this account, you can safely "
            "ignore this email.\n\n"
            "AttachFlow"
        ),
    )

    mail.send(message)


def verify_email(token):
    """
    Verify a user's email address using a raw verification token.

    Returns:
        tuple:
            (user, None) on success
            (None, error_response) on failure
    """

    if not token:
        return None, {
            "type": "validation",
            "message": "Verification token is required.",
        }

    token_hash = _hash_token(token)

    verification_token = (
        EmailVerificationToken.query.filter_by(
            token_hash=token_hash
        ).first()
    )

    if verification_token is None:
        return None, {
            "type": "invalid_token",
            "message": (
                "The verification link is invalid or has expired."
            ),
        }

    if verification_token.used_at is not None:
        return None, {
            "type": "already_used",
            "message": (
                "This verification link has already been used."
            ),
        }

    now = datetime.utcnow()

    if verification_token.expires_at <= now:
        return None, {
            "type": "invalid_token",
            "message": (
                "The verification link is invalid or has expired."
            ),
        }

    user = User.query.filter_by(
        id=verification_token.user_id
    ).first()

    if user is None:
        return None, {
            "type": "invalid_token",
            "message": (
                "The verification link is invalid or has expired."
            ),
        }

    if user.email_verified:
        verification_token.used_at = now
        db.session.commit()

        return None, {
            "type": "already_verified",
            "message": (
                "This email address has already been verified."
            ),
        }

    user.email_verified = True
    user.email_verified_at = now

    verification_token.used_at = now

    db.session.commit()

    return user, None


# ==========================================================
# LOGIN / SESSION ESTABLISHMENT
# ==========================================================

def authenticate_user(email, password, remember_me=False):
    """
    Authenticate a user and establish an application session.

    Returns:
        tuple:
            (user, None) on success
            (None, error_response) on failure
    """

    email = email.strip().lower()

    # --------------------------------------------------
    # Find account
    # --------------------------------------------------

    user = User.query.filter_by(
        email=email
    ).first()

    # Do not distinguish between a nonexistent email
    # and an incorrect password.
    if user is None:
        return None, {
            "type": "invalid_credentials",
            "message": "Invalid email or password.",
        }

    # --------------------------------------------------
    # Verify password
    # --------------------------------------------------

    if not check_password_hash(
        user.password_hash,
        password,
    ):
        return None, {
            "type": "invalid_credentials",
            "message": "Invalid email or password.",
        }

    # --------------------------------------------------
    # Account status
    # --------------------------------------------------

    if not user.is_active:
        return None, {
            "type": "inactive",
            "message": "This account is currently inactive.",
        }

    # --------------------------------------------------
    # Email verification
    # --------------------------------------------------

    if not user.email_verified:
        return None, {
            "type": "unverified",
            "message": (
                "Please verify your email address before logging in."
            ),
        }

    # --------------------------------------------------
    # Determine session expiration
    # --------------------------------------------------

    now = datetime.utcnow()

    if remember_me:
        expires_at = (
            now
            + timedelta(days=REMEMBER_ME_EXPIRY_DAYS)
        )
    else:
        expires_at = (
            now
            + timedelta(hours=SESSION_EXPIRY_HOURS)
        )

    # --------------------------------------------------
    # Generate secure session token
    # --------------------------------------------------

    session_token = secrets.token_urlsafe(32)

    # --------------------------------------------------
    # Create database session record
    # --------------------------------------------------

    user_session = UserSession(
        user_id=user.id,
        session_token=session_token,
        ip_address=request.remote_addr,
        user_agent=request.headers.get("User-Agent"),
        remember_me=remember_me,
        last_activity=now,
        expires_at=expires_at,
    )

    db.session.add(user_session)

    # Commit the database session first.
    db.session.commit()

    # --------------------------------------------------
    # Establish Flask-Login session
    # --------------------------------------------------

    login_user(
        user,
        remember=remember_me,
    )

    # IMPORTANT:
    # Store our database session token inside Flask's
    # session so logout_user_session() can identify
    # and invalidate the correct database record.
    session["session_token"] = session_token

    return user, None


# ==========================================================
# LOGOUT / SESSION INVALIDATION
# ==========================================================

def logout_user_session():
    """
    Invalidate the currently authenticated user's session.

    Returns:
        True if a session was invalidated.
        False if no authenticated session exists.
    """

    if not current_user.is_authenticated:
        return False

    session_token = session.get("session_token")

    if session_token:
        user_session = UserSession.query.filter_by(
            session_token=session_token,
            user_id=current_user.id,
        ).first()

        if user_session:
            db.session.delete(user_session)
            db.session.commit()

    logout_user()

    session.pop("session_token", None)

    return True