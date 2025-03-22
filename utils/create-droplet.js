import dotenv from 'dotenv'
import { editor, select } from '@inquirer/prompts'
import axios from 'axios'
import { NodeSSH } from 'node-ssh'
import * as fs from 'node:fs'

dotenv.config()

const digitalOceanApiUrl = 'https://api.digitalocean.com/v2'
const digitalOceanRequestConfig = {
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${process.env.DIGITAL_OCEAN_TOKEN}`
  }
}
const repositoryUrl = 'https://github.com/davidhernandeze/couchdb-minihosting.git'

console.log('Attempting connection to Digital Ocean API')
const { name } = await getDigitalOceanUser()
console.log(`✔ Logged in as ${name}`)

const dropletIp = await getDropletIp()
console.log('✔ Droplet IP', dropletIp)

const sshConnection = await getSSHConnection()
console.log('✔ Connected to droplet via SSH')

const output = await executeCommandOnDroplet('whoami')
console.log('✔ Executed command on droplet as', output.stdout)

await executeCommandOnDroplet('git', ['clone', '--quiet', repositoryUrl, '--branch', 'digital-ocean-deployer'], { cwd: '/root/', faultTolerant: true })
console.log('✔ Repository cloned')

const envFile = await buildEnvFile()
const echoArgs = ['-c', `echo '${envFile}' > .env`]
await executeCommandOnDroplet('bash', echoArgs, { cwd: '/root/couchdb-minihosting' })
console.log('✔ Environment file created')

await executeCommandOnDroplet('./install.sh', [], { cwd: '/root/couchdb-minihosting' })

terminate()

async function getDigitalOceanUser () {
  try {
    const { data } = await axios.get(`${digitalOceanApiUrl}/account`, digitalOceanRequestConfig)
    return data.account

  } catch (error) {
    console.error('Error connecting to Digital Ocean API ', error.response?.data)
    process.exit()
  }
}

async function getDropletIp () {
  try {
    const { data } = await axios.get(`${digitalOceanApiUrl}/droplets?page=1&per_page=100&tag_name=${process.env.DROPLETS_TAG}`, digitalOceanRequestConfig)
    const dropletOptions = data.droplets.map(droplet => ({
      name: `${droplet.name} - (${droplet.image.description})`,
      value: droplet
    }))

    const droplet = await select({
      message: 'Select a droplet to connect to',
      choices: dropletOptions,
    })
    return droplet.networks?.v4[0]?.ip_address

  } catch (error) {
    console.error('Error retrieving droplets', error)
    process.exit()
  }
}

async function getSSHConnection () {
  const ssh = new NodeSSH()
  try {
    console.log('Attempting to connect to droplet via SSH, ip:', dropletIp)
    await ssh.connect({
      host: dropletIp,
      username: 'root',
      privateKeyPath: '/Users/david/.ssh/id_ed25519'
    })
    return ssh

  } catch (error) {
    console.error('Error connecting to new droplet via SSH', error)
    terminate()
  }
}

async function executeCommandOnDroplet (command, args = [], options = {}) {
  console.log(`🚀  Executing command on droplet: ${command} ${args.join(' ')}`)
  try {
    return await sshConnection.exec(command, args, {
      ...options,
      stream: 'both',
      onStdout (chunk) {
        console.log(chunk.toString('utf8'))
      },
      onStderr (chunk) {
        if (options.faultTolerant) return
        console.log(chunk.toString('utf8'))
      },
    })

  } catch (error) {
    if (options.faultTolerant) return
    console.error('❌  Error executing command on droplet', error.message)
    terminate()
  }
}

async function buildEnvFile () {
  return editor({
    message: 'Edit the environment file',
    default: fs.readFileSync('../.env.default', 'utf8')
  })
}

function terminate () {
  console.log('Terminating connection')
  sshConnection.dispose()
  process.exit()
}

