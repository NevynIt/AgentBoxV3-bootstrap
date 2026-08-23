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

That Linux environment may be:

- an Ubuntu Multipass VM;
- Ubuntu under WSL2 with systemd enabled; or
- a native Ubuntu Linux machine.

AgentBox installation requires operating-system administrator rights for host packages, Docker, and optionally local Ollama. If your Linux user does not have passwordless sudo, the installer will explain why elevation is needed and `sudo` will ask for your Linux password directly. The password is handled by `sudo`; it is not read or stored by AgentBox.

Because AgentBox V3 is currently private, GitHub authentication is also required. The bootstrap launches the normal GitHub CLI browser/device login. The resulting credential is stored in the target Linux user's GitHub CLI configuration and is reused by normal AgentBox Git pull/push operations.

Do not paste GitHub tokens, provider API keys, SSH private keys, or AgentBox control passphrases into prompts or command-line arguments.

## Outside-Linux preparation

The public bootstrap cannot create its own Linux host. Create/enter the target first:

- **Multipass:** create or restore the Ubuntu VM, then `multipass shell <name>`.
- **WSL2:** install/enter an Ubuntu WSL2 distribution and ensure systemd is enabled.
- **Native Linux:** open a normal terminal on the Ubuntu host.

Then run the one-line bootstrap above.

## Scope

Keep this repository deliberately small. Product installation behavior must remain versioned with `NevynIt/AgentBoxV3/main` so the bootstrap cannot become a competing AgentBox lifecycle or configuration authority.
