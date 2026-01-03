# ruff: noqa: F821
#
# Jupyter Lab
#
c.ServerApp.ip = '*'
c.ServerApp.port = 13337
c.ServerApp.open_browser = False
c.ServerApp.password = u'argon2:$argon2id$v=19$m=10240,t=10,p=8$bY5rSBCPqjXzzLckWsGTLg$vYg9lyo18FG1kskOrT6ShA'
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