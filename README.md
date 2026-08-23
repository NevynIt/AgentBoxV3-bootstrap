# AgentBox V3 bootstrap

This repository is the tiny public entry point for installing the private AgentBox V3 Product.

The bootstrap does only enough work to obtain AgentBox itself:

1. verify a supported Linux environment;
2. install `git` and GitHub CLI when required;
3. authenticate the target Linux user to GitHub;
4. persist HTTPS Git credentials through `gh auth setup-git`;
5. verify access to `NevynIt/AgentBoxV3`;
6. clone/update `AgentBoxV3` `main` into `~/agentbox-runtime`; and
7. hand control to the Product-owned `install.sh` from that checkout.

The actual appliance installer, backend setup, Docker/Core/OpenWebUI configuration and self-development topology belong to the Product repository, not here.

## Start

Run this **inside the Linux environment that will become the AgentBox appliance**:

```bash
curl -fsSL https://raw.githubusercontent.com/NevynIt/AgentBoxV3-bootstrap/main/install.sh | bash
```

The fetch command itself needs `curl`. Current Ubuntu images commonly include it, but a minimal installation may not. If `curl` is missing, install only that fetch prerequisite first:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
```

Then rerun the bootstrap command.

That Linux environment may be:

- an Ubuntu Multipass VM;
- Ubuntu under WSL2 with systemd enabled;
- another Ubuntu VM; or
- a native Ubuntu Linux machine.

AgentBox installation requires operating-system administrator rights for host packages, Docker, and optionally local Ollama. The installer first probes a real privileged command with `sudo -n true`. If the host provides passwordless sudo—as standard Multipass/cloud images commonly do—it proceeds without asking for a password. Only a host that genuinely requires sudo authentication should display a password prompt. In that case, enter the Linux account password directly at the sudo prompt; AgentBox does not read or store it.

If you ever see a sudo password prompt on a VM where ordinary commands such as `sudo ls` are passwordless, abort with `Ctrl-C` and rerun the latest bootstrap. Older bootstrap revisions used `sudo -v`, which can prompt incorrectly on systems with mixed `PASSWD`/`NOPASSWD` sudoers rules.

Because AgentBox V3 is currently private, GitHub authentication is also required. The bootstrap launches the normal GitHub CLI browser/device login. The resulting credential is stored in the target Linux user's GitHub CLI configuration and is reused by normal AgentBox Git pull/push operations.

After handoff, the Product installer front-loads the remaining human work. It prepares the small prerequisite set needed for the interview, verifies GitHub and temporary reconstruction-Codex authentication, collects backend/model/secret/control-passphrase choices, shows one non-secret installation plan, and asks for a final `Proceed` confirmation. After that point installation is unattended: package installation, repository convergence, Docker builds, model downloads, backend/Core reconciliation, temporary reconstruction and final health checks either complete without further questions or fail with a diagnostic for a later rerun.

On a host with passworded sudo, the accepted Product run keeps the already-authorized sudo timestamp alive so a long build or model download does not unexpectedly stop later for another password. WSL2 without systemd is the deliberate exception: enabling systemd requires `wsl --shutdown` and a rerun before the Product configuration interview begins.

Do not paste GitHub tokens, provider API keys, sudo passwords, SSH private keys, or AgentBox control passphrases into prompts or command-line arguments.

## Outside-Linux preparation

The public bootstrap cannot create its own Linux host. Create/enter the target first:

- **Multipass:** create or restore the Ubuntu VM, then `multipass shell <name>`.
- **WSL2:** install/enter an Ubuntu WSL2 distribution; the Product installer can help enable systemd if needed.
- **Native Linux:** open a normal terminal on the Ubuntu host.

Then run the bootstrap above.

## Scope

Keep this repository deliberately small. Product installation behavior must remain versioned with `NevynIt/AgentBoxV3/main` so the bootstrap cannot become a competing AgentBox lifecycle or configuration authority.
