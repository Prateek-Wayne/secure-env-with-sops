# Secure Environment Management with SOPS and GPG

This is a demonstration repository that shows how to manage encrypted secrets within a team using [Mozilla SOPS](https://github.com/mozilla/sops) and GPG keys from GitHub profiles.

The repository contains two common secret file types (`.env` and `.yaml`) to demonstrate the workflow.

## Onboarding a New Teammate

This process involves two roles: the **Teammate** who needs access, and the **Admin** who can approve access and rotate the secrets.

### Step 1: For the New Teammate

As a new team member, you need to request access to the secrets.

1.  Ensure you have a GPG key uploaded to your GitHub account. SOPS will use this to find your public key.
2.  Create a new branch from `main`.
3.  In your branch, add your GitHub username to the `.sops.yaml` file under the `github` list.
4.  Create a Pull Request (PR) to merge your branch into `main`.

### Step 2: For the Admin

The admin must re-encrypt the secrets with the new teammate's public key.

1.  Check out the teammate's PR branch locally.
2.  Navigate to the `tools` directory and run the key synchronization script. This will find all `.enc.` files and re-encrypt them using the public keys of all users listed in `.sops.yaml`.

    ```bash
    cd tools
    npm install
    node index.js
    ```

3.  The script will update the encrypted secret files. Commit these changes and push them to the teammate's branch.
4.  You can now merge the Pull Request into `main`.

### Step 3: For the New Teammate (Final)

Once the PR is merged, you can decrypt the secrets.

1.  Pull the latest changes from the `main` branch.
2.  You can now use the decryption scripts to access the secret values locally:
    - To decrypt `.env.dev.enc`:
      ```bash
      ./decrypt-env.sh
      ```
    - To decrypt `secrets.enc.yaml`:
      ```bash
      ./decrypt-yaml.sh
      ```
