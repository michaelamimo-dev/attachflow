import re

from email_validator import EmailNotValidError, validate_email
from flask import request


class RegistrationForm:
    """Validates incoming user registration data."""

    required_fields = [
        "first_name",
        "last_name",
        "email",
        "password",
        "confirm_password",
        "university",
        "student_registration_number",
    ]

    def __init__(self):
        self.data = request.get_json(silent=True) or {}
        self.errors = {}

    def validate(self):
        self._validate_required_fields()

        if self.errors:
            return False

        self._validate_name("first_name", "First name")
        self._validate_name("last_name", "Last name")
        self._validate_email()
        self._validate_password()
        self._validate_confirm_password()
        self._validate_university()
        self._validate_registration_number()

        return not self.errors

    def _validate_required_fields(self):
        for field in self.required_fields:
            value = self.data.get(field)

            if value is None or (
                isinstance(value, str) and not value.strip()
            ):
                self.errors.setdefault(field, []).append(
                    "This field is required."
                )

    def _validate_name(self, field, label):
        value = self.data.get(field)

        if not isinstance(value, str):
            self.errors.setdefault(field, []).append(
                f"{label} must contain valid text."
            )
            return

        if not value.strip():
            self.errors.setdefault(field, []).append(
                f"{label} must not be blank."
            )

    def _validate_email(self):
        email = self.data.get("email")

        if not isinstance(email, str):
            self.errors.setdefault("email", []).append(
                "Enter a valid email address."
            )
            return

        try:
            result = validate_email(
                email.strip(),
                check_deliverability=False,
            )
            self.data["email"] = result.normalized
        except EmailNotValidError:
            self.errors.setdefault("email", []).append(
                "Enter a valid email address."
            )

    def _validate_password(self):
        password = self.data.get("password")

        if not isinstance(password, str):
            self.errors.setdefault("password", []).append(
                "Password must contain at least 8 characters."
            )
            return

        if len(password) < 8:
            self.errors.setdefault("password", []).append(
                "Password must contain at least 8 characters."
            )

        if not re.search(r"[A-Z]", password):
            self.errors.setdefault("password", []).append(
                "Password must contain at least one uppercase letter."
            )

        if not re.search(r"[a-z]", password):
            self.errors.setdefault("password", []).append(
                "Password must contain at least one lowercase letter."
            )

        if not re.search(r"\d", password):
            self.errors.setdefault("password", []).append(
                "Password must contain at least one numeric digit."
            )

        if not re.search(r"[^A-Za-z0-9]", password):
            self.errors.setdefault("password", []).append(
                "Password must contain at least one special character."
            )

    def _validate_confirm_password(self):
        password = self.data.get("password")
        confirm_password = self.data.get("confirm_password")

        if (
            isinstance(password, str)
            and isinstance(confirm_password, str)
            and password != confirm_password
        ):
            self.errors.setdefault("confirm_password", []).append(
                "Passwords must match."
            )

    def _validate_university(self):
        university = self.data.get("university")

        if not isinstance(university, str):
            self.errors.setdefault("university", []).append(
                "University must contain valid text."
            )
            return

        if not university.strip():
            self.errors.setdefault("university", []).append(
                "University must not be blank."
            )

    def _validate_registration_number(self):
        registration_number = self.data.get(
            "student_registration_number"
        )

        if not isinstance(registration_number, str):
            self.errors.setdefault(
                "student_registration_number", []
            ).append(
                "Student registration number must contain valid text."
            )
            return

        if not registration_number.strip():
            self.errors.setdefault(
                "student_registration_number", []
            ).append(
                "Student registration number must not be blank."
            )