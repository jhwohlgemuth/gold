# ruff: noqa: F821
#
# Jupyter Lab
#
import os
from pathlib import Path

from jupyter_server.auth import passwd

c.ServerApp.ip = '*'
c.ServerApp.port = 13337
c.ServerApp.open_browser = False
c.ServerApp.keyfile = u"/home/nonroot/certs/my.key"
c.ServerApp.certfile = u"/home/nonroot/certs/my.pem"
c.ServerApp.root_dir = "/home/nonroot/dev"
c.ServerApp.logging_config = {
    "version": 1,
    "handlers": {
        "logfile": {
            "class": "logging.FileHandler",
            "level": "DEBUG",
            "filename": "jupyter_server.log",
        },
    },
    "loggers": {
        "ServerApp": {
            "level": "DEBUG",
            "handlers": ["logfile"],
        },
    },
}

# Load operator settings before enforcing the container's login contract.
custom_config = os.environ.get("JUPYTER_CONFIG")
if custom_config and Path(custom_config).resolve() != Path(__file__).resolve():
    if not Path(custom_config).is_file():
        raise FileNotFoundError("JUPYTER_CONFIG must name an existing Python config file")
    load_subconfig(custom_config)

password_hash = os.environ.get("JUPYTER_PASSWORD_HASH", "")
password = os.environ.pop("JUPYTER_PASSWORD", "")
if not password_hash and not password:
    raise RuntimeError("Set JUPYTER_PASSWORD or JUPYTER_PASSWORD_HASH before starting Jupyter")

# Environment credentials override custom configuration. Never write the secret
# or its hash into a config file or pass it as a process argument.
for legacy_setting in ("password", "password_required", "token", "allow_password_change"):
    c.ServerApp.pop(legacy_setting, None)
c.ServerApp.identity_provider_class = "jupyter_server.auth.identity.PasswordIdentityProvider"
c.ServerApp.login_handler_class = "jupyter_server.auth.login.LoginHandler"
# Extensions may load this file again. Retain only the hash for those loads,
# so the plaintext password is not inherited by notebook kernels.
password_hash = password_hash or passwd(password)
os.environ["JUPYTER_PASSWORD_HASH"] = password_hash
c.PasswordIdentityProvider.hashed_password = password_hash
c.PasswordIdentityProvider.password_required = True
c.PasswordIdentityProvider.allow_password_change = False
c.PasswordIdentityProvider.token = ""
c.IdentityProvider.token = ""
os.environ.pop("JUPYTER_TOKEN", None)
os.environ.pop("JUPYTER_TOKEN_FILE", None)
