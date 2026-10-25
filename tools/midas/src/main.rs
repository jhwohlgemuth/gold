//! Update Gold dotfiles and restow configuration packages
use clap::Command as ClapCommand;
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode, Output};

fn main() -> ExitCode {
    let matches = ClapCommand::new("midas")
        .version(env!("CARGO_PKG_VERSION"))
        .about("Update Gold dotfiles and restow configuration packages")
        .subcommand_required(true)
        .subcommand(
            ClapCommand::new("update")
                .visible_alias("gold")
                .about("Pull a clean dotfiles checkout and restow Gold commands"),
        )
        .subcommand(
            ClapCommand::new("opencode")
                .about("Restow the opencode package from the dotfiles checkout"),
        )
        .get_matches();

    match matches.subcommand_name() {
        Some("update" | "gold") => report(update_gold()),
        Some("opencode") => report(restow_opencode()),
        _ => ExitCode::from(2),
    }
}
fn report(result: Result<(), String>) -> ExitCode {
    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(message) => {
            eprintln!("midas: {message}");
            ExitCode::FAILURE
        }
    }
}
fn home_dir() -> Result<PathBuf, String> {
    env::var_os("HOME")
        .filter(|value| !value.is_empty())
        .map(PathBuf::from)
        .ok_or_else(|| "HOME is not set".to_owned())
}
fn dotfiles_dir(home: &Path) -> PathBuf {
    env::var_os("GOLD_DOTFILES")
        .filter(|value| !value.is_empty())
        .map(PathBuf::from)
        .unwrap_or_else(|| home.join(".dotfiles"))
}
fn checked(command: &mut Command, label: &str) -> Result<Output, String> {
    command
        .output()
        .map_err(|error| format!("cannot run {label}: {error}"))
        .and_then(|output| {
            if output.status.success() {
                Ok(output)
            } else {
                let stderr = String::from_utf8_lossy(&output.stderr);
                let detail = stderr.trim();
                if detail.is_empty() {
                    Err(format!("{label} failed with {}", output.status))
                } else {
                    Err(format!("{label} failed: {detail}"))
                }
            }
        })
}
fn verify_dotfiles_root(dotfiles: &Path) -> Result<(), String> {
    if dotfiles.is_dir() {
        checked(
            Command::new("git")
                .arg("-C")
                .arg(dotfiles)
                .args(["rev-parse", "--show-prefix"]),
            "git rev-parse",
        )
        .and_then(|output| {
            if String::from_utf8_lossy(&output.stdout).trim().is_empty() {
                Ok(())
            } else {
                Err(format!(
                    "dotfiles path must be the repository root: {}",
                    dotfiles.display()
                ))
            }
        })
    } else {
        Err(format!(
            "dotfiles directory does not exist: {}",
            dotfiles.display()
        ))
    }
}
fn ensure_clean(dotfiles: &Path) -> Result<(), String> {
    checked(
        Command::new("git").arg("-C").arg(dotfiles).args([
            "status",
            "--porcelain=v1",
            "--untracked-files=all",
        ]),
        "git status",
    )
    .and_then(|output| {
        if output.stdout.is_empty() {
            Ok(())
        } else {
            Err(format!(
                "dotfiles checkout has local changes; resolve or save them before updating: {}",
                dotfiles.display()
            ))
        }
    })
}
fn restow(dotfiles: &Path, target: &Path, package: &str) -> Result<(), String> {
    if dotfiles.join(package).is_dir() {
        fs::create_dir_all(target)
            .map_err(|error| format!("cannot create {}: {error}", target.display()))
            .and_then(|()| {
                checked(
                    Command::new("stow")
                        .arg("--dir")
                        .arg(dotfiles)
                        .arg("--target")
                        .arg(target)
                        .arg("--restow")
                        .arg(package),
                    "stow",
                )
                .map(|_| ())
            })
    } else {
        Err(format!(
            "package {package} was not found in {}",
            dotfiles.display()
        ))
    }
}
fn update_gold() -> Result<(), String> {
    home_dir().and_then(|home| {
        let dotfiles = dotfiles_dir(&home);
        verify_dotfiles_root(&dotfiles)
            .and_then(|()| ensure_clean(&dotfiles))
            .and_then(|()| {
                checked(
                    Command::new("git").arg("-C").arg(&dotfiles).args([
                        "pull",
                        "--ff-only",
                        "origin",
                        "main",
                    ]),
                    "git pull",
                )
            })
            .and_then(|_| restow(&dotfiles, &home.join(".local/bin"), "gold"))
            .map(|()| println!("Gold dotfiles updated and restowed."))
    })
}
fn restow_opencode() -> Result<(), String> {
    home_dir().and_then(|home| {
        let dotfiles = dotfiles_dir(&home);
        restow(&dotfiles, &home, "opencode").map(|()| println!("Opencode configuration restowed."))
    })
}
