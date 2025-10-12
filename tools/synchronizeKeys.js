import yaml from 'js-yaml';
import fs from 'fs';
import gpg from 'gpg';
import * as openpgp from 'openpgp';
import util from 'util';
import chalk from 'chalk';
import { text } from 'stream/consumers';

const importKeyPromise = util.promisify(gpg.importKey);

const configPath = '../.sops.yaml';

export const synchronizeKeys = async () => {
  let githubUsers = [];
  let configData;
  try {
    configData = yaml.load(fs.readFileSync(configPath, 'utf8'));
    githubUsers = configData.creation_rules[0].github;
  } catch (err) {
    console.log(err);
  }

  console.log(`Found ${githubUsers.length} usernames in the config file`);
  console.log(githubUsers.map((user) => `- ${user}`).join('\n'));
  console.log('\n');

  const keyFingerprints = [];
  for (const user of githubUsers) {
    console.log(chalk.blue(`User: ${user}`));
    let httpResponse;
    const githubKeyUrl = `https://github.com/${user}.gpg`;
    try {
      httpResponse = await fetch(githubKeyUrl);
    } catch (error) {
      console.error(
        `Error fetching key for ${user} at ${githubKeyUrl} : ${error}`
      );
      console.log('-----\n');
      continue;
    }

    const publicKey = await httpResponse.text();

    if (
      !publicKey ||
      publicKey.indexOf("This user hasn't uploaded any GPG keys") > -1
    ) {
      console.error(
        chalk.red(`${user} has not added a key to their GH account`)
      );
      console.log('-----\n');
      continue;
    }
    console.log(chalk.green(`Key found on GitHub at ${githubKeyUrl}`));

    let fingerprint;
    try {
      const gpgKey = await openpgp.readKeys({ armoredKeys: publicKey });
      fingerprint = await gpgKey[0].getFingerprint();
    } catch (error) {
      console.error(
        chalk.red(
          `Error reading key from GitHub for ${user} at ${githubKeyUrl}: ${error}`
        )
      );
      console.log('-----\n');
      continue;
    }

    console.log(`${user} - Importing key with fingerprint: ${fingerprint}`);
    try {
      await importKeyPromise(publicKey);
      console.log(chalk.green('Import successful'));
    } catch (error) {
      console.error(
        chalk.red(`Error importing key into your GPG keychain: ${error}`)
      );
    }

    keyFingerprints.push(fingerprint);
  }

  const allFingerprints = keyFingerprints.join(',');

  configData.creation_rules[0].pgp = allFingerprints;

  fs.writeFileSync(configPath, yaml.dump(configData, { lineWidth: 40 }));
  console.log(chalk.green(`SOPS config updated at ${configPath}\n`));
  console.log(
    chalk.bgCyan(
      chalk.bold(
        `RUN: sops updatekeys secrets.dev.enc.yaml to re-encrypt the secrets with any new keys`
      )
    )
  );
};
