from flask import jsonify, request

from app.auth import auth_bp
from app.auth.forms import RegistrationForm
from app.auth.services import (
    authenticate_user,
    logout_user_session,
    register_user,
    send_verification_email,
    verify_email,
)


# ==========================================================
# HEALTH
# ==========================================================

@auth_bp.get("/health")
def auth_health():
    return jsonify({
        "success": True,
        "message": "Authentication API is available."
    }), 200


# ==========================================================
# REGISTER
# ==========================================================

@auth_bp.post("/register")
def register():
    form = RegistrationForm()

    if not form.validate():
        return jsonify({
            "success": False,
            "message": "Please correct the highlighted fields.",
            "errors": form.errors,
        }), 422

    user, result = register_user(form.data)

    if user is None:
        if result["type"] == "duplicate":
            return jsonify({
                "success": False,
                "message": result["message"],
            }), 409

        if result["type"] == "validation":
            return jsonify({
                "success": False,
                "message": (
                    "Please correct the highlighted fields."
                ),
                "errors": {
                    result["field"]: [result["message"]]
                },
            }), 422

    try:
        send_verification_email(user, result)
    except Exception:
        return jsonify({
            "success": False,
            "message": (
                "Account was created, but the verification email "
                "could not be sent."
            ),
        }), 500

    return jsonify({
        "success": True,
        "message": (
            "Account created successfully. "
            "Please verify your email."
        ),
    }), 201


# ==========================================================
# VERIFY EMAIL
# ==========================================================

@auth_bp.post("/verify-email")
def verify_email_route():
    data = request.get_json(silent=True) or {}

    token = data.get("token")

    user, error = verify_email(token)

    if error:
        if error["type"] == "validation":
            return jsonify({
                "success": False,
                "message": error["message"],
            }), 422

        if error["type"] == "already_verified":
            return jsonify({
                "success": False,
                "message": error["message"],
            }), 400

        return jsonify({
            "success": False,
            "message": error["message"],
        }), 400

    return jsonify({
        "success": True,
        "message": "Email verified successfully.",
    }), 200


# ==========================================================
# LOGIN
# ==========================================================

@auth_bp.post("/login")
def login():
    data = request.get_json(silent=True) or {}

    email = data.get("email", "")
    password = data.get("password", "")
    remember_me = data.get("remember_me", False)

    # --------------------------------------------------
    # Basic request validation
    # --------------------------------------------------

    errors = {}

    if not email:
        errors["email"] = [
            "Email is required."
        ]

    if not password:
        errors["password"] = [
            "Password is required."
        ]

    if not isinstance(remember_me, bool):
        errors["remember_me"] = [
            "Remember me must be a boolean value."
        ]

    if errors:
        return jsonify({
            "success": False,
            "message": "Please correct the highlighted fields.",
            "errors": errors,
        }), 422

    # --------------------------------------------------
    # Authenticate
    # --------------------------------------------------

    user, error = authenticate_user(
        email=email,
        password=password,
        remember_me=remember_me,
    )

    if error:
        if error["type"] == "invalid_credentials":
            return jsonify({
                "success": False,
                "message": error["message"],
            }), 401

        if error["type"] == "unverified":
            return jsonify({
                "success": False,
                "message": error["message"],
            }), 403

        if error["type"] == "inactive":
            return jsonify({
                "success": False,
                "message": error["message"],
            }), 403

    # --------------------------------------------------
    # Successful login
    # --------------------------------------------------

    return jsonify({
        "success": True,
        "message": "Login successful.",
        "data": {
            "user": {
                "id": str(user.id),
                "first_name": user.first_name,
                "last_name": user.last_name,
                "email": user.email,
                "role": user.role,
            }
        }
    }), 200


# ==========================================================
# LOGOUT
# ==========================================================

@auth_bp.post("/logout")
def logout():
    success = logout_user_session()

    if not success:
        return jsonify({
            "success": False,
            "message": "You are not currently authenticated.",
        }), 401

    return jsonify({
        "success": True,
        "message": "Logout successful.",
    }), 200