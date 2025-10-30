# Secure Environment Variables with SOPS

A secure way to manage environment variables and secrets using [SOPS (Secrets OPerationS)](https://github.com/mozilla/sops) with PGP encryption. This project demonstrates how to encrypt sensitive configuration data and automatically synchronize team member GPG keys from GitHub.

## 🔐 Features

- **PGP Encryption**: Secure your secrets using GPG/PGP keys
- **Team Collaboration**: Automatically fetch and synchronize team member GPG keys from GitHub
- **Version Control Safe**: Encrypted files can be safely committed to git
- **Easy Key Management**: Automated key import and trust configuration
- **Multiple Environments**: Support for different environment configurations (dev, staging, prod)

## 🛠️ Prerequisites

- [SOPS](https://github.com/mozilla/sops) - Install via `brew install sops` (macOS) or download from releases
- [GPG](https://gnupg.org/) - Install via `brew install gnupg` (macOS)
- [Node.js](https://nodejs.org/) - For running the key synchronization tools
- A GPG key pair uploaded to your GitHub account

## 📁 Project Structure

```
├── .sops.yaml                 # SOPS configuration file
├── secrets.dev.enc.yaml       # Encrypted secrets file
├── secrets.dev.env            # Decrypted environment file (gitignored)
├── sample.txt.gpg            # Example encrypted file
├── tools/
│   ├── package.json          # Node.js dependencies
│   ├── index.js              # Main entry point
│   └── synchronizeKeys.js    # Key synchronization script
└── README.md
```

## 🚀 Quick Start

### 1. Generate a GPG Key (if you don't have one)

```bash
gpg --full-generate-key
```

Follow the prompts and choose:

- Key type: RSA
- Key size: 3072 or 4096
- Expiration: Your preference
- Real name and email

### 2. Upload Your GPG Key to GitHub

```bash
# Export your public key
gpg --armor --export your-email@example.com

# Copy the output and add it to GitHub > Settings > SSH and GPG keys
```

### 3. Configure Team Members

Edit `.sops.yaml` to add your team members' GitHub usernames:

```yaml
creation_rules:
  - pgp: >-
      your-key-fingerprint,teammate1-key-fingerprint
    github:
      - your-github-username
      - teammate1-github-username
```

### 4. Install Dependencies and Sync Keys(For Admins)

```bash
cd tools
npm install
node index.js
```

This will:

- Fetch GPG keys from GitHub for all listed users
- Import and trust the keys locally
- Update the SOPS configuration

### 5. Create/Edit Encrypted Secrets

```bash
# Create a new encrypted file
sops secrets.dev.enc.yaml

# Edit an existing encrypted file
sops secrets.dev.enc.yaml
```

### 6. Decrypt for Use

```bash
# View decrypted content
sops -d secrets.dev.enc.yaml

# Export to environment file
sops -d secrets.dev.enc.yaml > secrets.dev.env
```

## 🔧 Configuration

### SOPS Configuration (`.sops.yaml`)

```yaml
creation_rules:
  - pgp: >-
      fingerprint1,fingerprint2,fingerprint3
    github:
      - github-user1
      - github-user2
      - github-user3
```

### Environment Variables Structure

Your encrypted `secrets.dev.enc.yaml` might look like:

```yaml
api_key: your-api-key
database_password: super-secret-password
secret_token: jwt-secret-token
smtp_password: email-password
```

## 🔄 Workflow

### Adding a New Team Member

1. Add their GitHub username to `.sops.yaml` under the `github` section
2. Run the key synchronization:
   ```bash
   cd tools
   node index.js
   ```
3. Update existing encrypted files to include the new key:
   ```bash
   sops updatekeys secrets.dev.enc.yaml
   ```

### Updating Secrets

```bash
# Edit the encrypted file
sops secrets.dev.enc.yaml

# Commit the changes (encrypted file is safe to commit)
git add secrets.dev.enc.yaml
git commit -m "Update API keys"
```

### Using in Applications

```bash
# Method 1: Export to environment file
sops -d secrets.dev.enc.yaml > secrets.dev.env
source secrets.dev.env

# Method 2: Direct environment export
export $(sops -d secrets.dev.enc.yaml | grep -v '^#' | xargs)

# Method 3: Use with docker-compose
sops -d secrets.dev.enc.yaml > .env
docker-compose up
```

## 🛡️ Security Best Practices

1. **Never commit decrypted files**: Add `*.env` to `.gitignore`
2. **Rotate keys regularly**: Update GPG keys and re-encrypt files periodically
3. **Use different keys per environment**: Separate keys for dev/staging/prod
4. **Backup your private keys**: Store them securely offline
5. **Verify team member identities**: Ensure GitHub accounts belong to actual team members

## 🔍 Troubleshooting

### "No pinentry" Error

```bash
# Configure pinentry for macOS
echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
chmod 600 ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent

# Set TTY for terminal use
export GPG_TTY=$(tty)
```

### "Unusable public key" Error

```bash
# Trust the key manually
echo "KEY_FINGERPRINT:6:" | gpg --import-ownertrust
```

### Key Not Found

```bash
# Re-sync keys
cd tools
node index.js
```

## 📚 Commands Reference

| Command                                | Description                   |
| -------------------------------------- | ----------------------------- |
| `sops secrets.dev.enc.yaml`            | Edit encrypted file           |
| `sops -d secrets.dev.enc.yaml`         | Decrypt and display           |
| `sops updatekeys secrets.dev.enc.yaml` | Add new keys to existing file |
| `gpg --list-keys`                      | List all GPG keys             |
| `gpg --list-secret-keys`               | List private keys             |
| `node tools/index.js`                  | Sync team member keys         |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your GPG key to GitHub
4. Update the team configuration
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Resources

- [SOPS Documentation](https://github.com/mozilla/sops)
- [GPG Tutorial](https://gnupg.org/gph/en/manual.html)
- [GitHub GPG Keys](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account)
