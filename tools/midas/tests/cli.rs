//! Integration tests for the Midas CLI.

#![cfg(unix)]

use core::sync::atomic::{AtomicU64, Ordering};
use std::env;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};

type TestResult<T = ()> = Result<T, Box<dyn core::error::Error>>;

static NEXT_ID: AtomicU64 = AtomicU64::new(0);

fn boxed<T, E: core::error::Error + 'static>(result: Result<T, E>) -> TestResult<T> {
    result.map_err(Into::into)
}

struct Fixture {
    root: PathBuf,
    home: PathBuf,
    dotfiles: PathBuf,
    seed: PathBuf,
    stow_log: PathBuf,
    bin_dir: PathBuf,
}

impl Fixture {
    fn new() -> TestResult<Self> {
        let id = NEXT_ID.fetch_add(1, Ordering::Relaxed);
        let root = env::temp_dir().join(format!("midas-test-{}-{id}", std::process::id()));
        let home = root.join("home");
        let bin_dir = root.join("bin");
        let stow = bin_dir.join("stow");
        let remote = root.join("remote.git");
        let seed = root.join("seed");
        let dotfiles = root.join("dotfiles");

        boxed(fs::create_dir(&root))
            .and_then(|()| boxed(fs::create_dir(&home)))
            .and_then(|()| boxed(fs::create_dir(&bin_dir)))
            .and_then(|()| {
                boxed(fs::write(
                    &stow,
                    "#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$MIDAS_STOW_LOG\"\nif [ -n \"$MIDAS_STOW_EXIT\" ]; then exit \"$MIDAS_STOW_EXIT\"; fi\nexit 0\n",
                ))
            })
            .and_then(|()| boxed(fs::metadata(&stow)))
            .and_then(|metadata| {
                let mut permissions = metadata.permissions();
                permissions.set_mode(0o755);
                boxed(fs::set_permissions(&stow, permissions))
            })
            .and_then(|()| {
                git(Command::new("git")
                    .args(["init", "--quiet", "--bare", "--initial-branch=main"])
                    .arg(&remote))
            })
            .and_then(|()| git(Command::new("git").arg("clone").arg(&remote).arg(&seed)))
            .and_then(|()| boxed(fs::create_dir(seed.join("gold"))))
            .and_then(|()| boxed(fs::write(seed.join("gold/marker"), "initial\n")))
            .and_then(|()| commit(&seed, "initial"))
            .and_then(|()| {
                git(Command::new("git")
                    .arg("-C")
                    .arg(&seed)
                    .args(["push", "origin", "main"]))
            })
            .and_then(|()| git(Command::new("git").arg("clone").arg(&remote).arg(&dotfiles)))
            .map(|()| Self {
                stow_log: root.join("stow.log"),
                root,
                home,
                dotfiles,
                seed,
                bin_dir,
            })
    }

    fn command(&self) -> TestResult<Command> {
        let mut paths = vec![self.bin_dir.clone()];
        paths.extend(env::split_paths(&env::var_os("PATH").unwrap_or_default()));
        boxed(env::join_paths(paths)).map(|path| {
            let mut command = Command::new(env!("CARGO_BIN_EXE_midas"));
            command
                .env("HOME", &self.home)
                .env("GOLD_DOTFILES", &self.dotfiles)
                .env("MIDAS_STOW_LOG", &self.stow_log)
                .env("PATH", path);
            command
        })
    }

    fn push_update(&self) -> TestResult {
        boxed(fs::write(self.seed.join("gold/marker"), "updated\n"))
            .and_then(|()| commit(&self.seed, "update"))
            .and_then(|()| {
                git(Command::new("git")
                    .arg("-C")
                    .arg(&self.seed)
                    .args(["push", "origin", "main"]))
            })
    }
}

impl Drop for Fixture {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn git(command: &mut Command) -> TestResult {
    boxed(command.output()).map(|output| {
        assert!(
            output.status.success(),
            "git failed: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    })
}

fn commit(repo: &Path, message: &str) -> TestResult {
    git(Command::new("git").arg("-C").arg(repo).args(["add", "."])).and_then(|()| {
        git(Command::new("git").arg("-C").arg(repo).args([
            "-c",
            "user.name=Midas Test",
            "-c",
            "user.email=midas@example.invalid",
            "commit",
            "--quiet",
            "-m",
            message,
        ]))
    })
}

fn error(output: &Output) -> String {
    String::from_utf8_lossy(&output.stderr).into_owned()
}

fn run(fixture: &Fixture, arguments: &[&str]) -> TestResult<Output> {
    fixture
        .command()
        .and_then(|mut command| boxed(command.args(arguments).output()))
}

#[test]
fn cli_help_version_and_invalid_arguments() -> TestResult {
    let binary = env!("CARGO_BIN_EXE_midas");
    boxed(Command::new(binary).arg("--help").output())
        .and_then(|help| {
            assert!(help.status.success());
            let help_text = String::from_utf8_lossy(&help.stdout);
            assert!(help_text.contains("update"));
            assert!(help_text.contains("gold"));
            assert!(help_text.contains("opencode"));
            boxed(Command::new(binary).arg("--version").output())
        })
        .and_then(|version| {
            assert!(version.status.success());
            assert_eq!(
                String::from_utf8_lossy(&version.stdout).trim(),
                format!("midas {}", env!("CARGO_PKG_VERSION"))
            );
            [vec![], vec!["unknown"], vec!["update", "extra"]]
                .into_iter()
                .map(|arguments| boxed(Command::new(binary).args(arguments).output()))
                .collect::<TestResult<Vec<_>>>()
        })
        .map(|invalid_outputs| {
            for invalid in invalid_outputs {
                assert_eq!(invalid.status.code(), Some(2));
                assert!(!invalid.stderr.is_empty());
            }
        })
}

#[test]
fn clean_update_fast_forwards_and_restows_gold() -> TestResult {
    Fixture::new().and_then(|fixture| {
        fixture
            .push_update()
            .and_then(|()| run(&fixture, &["update"]))
            .and_then(|output| {
                assert!(output.status.success(), "{}", error(&output));
                boxed(fs::read_to_string(fixture.dotfiles.join("gold/marker")))
            })
            .and_then(|marker| {
                assert_eq!(marker, "updated\n");
                assert!(fixture.home.join(".local/bin").is_dir());
                boxed(fs::read_to_string(&fixture.stow_log))
            })
            .map(|args| {
                assert!(args.contains(&fixture.dotfiles.display().to_string()));
                assert!(args.contains(&fixture.home.join(".local/bin").display().to_string()));
                assert!(args.ends_with("gold\n"));
            })
    })
}

#[test]
fn dirty_checkout_is_preserved_and_stow_is_not_called() -> TestResult {
    Fixture::new().and_then(|fixture| {
        fixture
            .push_update()
            .and_then(|()| {
                boxed(fs::write(
                    fixture.dotfiles.join("gold/marker"),
                    "local edit\n",
                ))
            })
            .and_then(|()| run(&fixture, &["gold"]))
            .and_then(|output| {
                assert!(!output.status.success());
                assert!(error(&output).contains("local changes"));
                boxed(fs::read_to_string(fixture.dotfiles.join("gold/marker")))
            })
            .map(|marker| {
                assert_eq!(marker, "local edit\n");
                assert!(!fixture.stow_log.exists());
            })
    })
}

#[test]
fn git_failure_is_reported_without_restowing() -> TestResult {
    Fixture::new().and_then(|fixture| {
        git(Command::new("git")
            .arg("-C")
            .arg(&fixture.dotfiles)
            .args(["remote", "remove", "origin"]))
        .and_then(|()| run(&fixture, &["update"]))
        .map(|output| {
            assert!(!output.status.success());
            assert!(error(&output).contains("git pull failed"));
            assert!(!fixture.stow_log.exists());
        })
    })
}

#[test]
fn stow_failure_is_reported() -> TestResult {
    Fixture::new().and_then(|fixture| {
        fixture
            .command()
            .and_then(|mut command| {
                boxed(command.env("MIDAS_STOW_EXIT", "42").arg("update").output())
            })
            .map(|output| {
                assert!(!output.status.success());
                assert!(error(&output).contains("stow failed"));
            })
    })
}

#[test]
fn opencode_requires_an_existing_package() -> TestResult {
    Fixture::new().and_then(|fixture| {
        run(&fixture, &["opencode"])
            .and_then(|missing| {
                assert!(!missing.status.success());
                assert!(error(&missing).contains("package opencode was not found"));
                assert!(!fixture.stow_log.exists());
                boxed(fs::create_dir(fixture.dotfiles.join("opencode")))
            })
            .and_then(|()| run(&fixture, &["opencode"]))
            .and_then(|installed| {
                assert!(installed.status.success(), "{}", error(&installed));
                boxed(fs::read_to_string(&fixture.stow_log))
            })
            .map(|args| {
                assert!(args.contains(&fixture.home.display().to_string()));
                assert!(args.ends_with("opencode\n"));
            })
    })
}
