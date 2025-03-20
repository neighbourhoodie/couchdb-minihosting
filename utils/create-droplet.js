import dotenv from 'dotenv'
import { select } from '@inquirer/prompts'
import axios from 'axios'
import { NodeSSH } from 'node-ssh'

dotenv.config()

console.log('Attempting connection to Digital Ocean API')
const digitalOceanApiUrl = 'https://api.digitalocean.com/v2'
const digitalOceanRequestConfig = {
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${process.env.DIGITAL_OCEAN_TOKEN}`
  }
}

try {
  const { data } = await axios.get(`${digitalOceanApiUrl}/account`, digitalOceanRequestConfig)
  console.log(`✅  Logged in as ${data.account?.name}`)
} catch (error) {
  console.error('Error connecting to Digital Ocean API ', error.response?.data)
  process.exit()
}

let dropletIP = ''
try {
  const { data } = await axios.get(`${digitalOceanApiUrl}/droplets?page=1&per_page=100`, digitalOceanRequestConfig)
  console.log(`✅  Droplets retrieved: ${data.droplets?.length} of ${data.meta.total}`)
  const dropletOptions = data.droplets.map(droplet => ({
    name: `${droplet.name} - (${droplet.image.description})`,
    value: droplet
  }))

  const droplet = await select({
    message: 'Select a droplet to connect to',
    choices: dropletOptions,
  })
  dropletIP = droplet.networks?.v4[0]?.ip_address
  console.log('✅  Droplet IP', dropletIP)
} catch (error) {
  console.error('Error retrieving droplets', error)
  process.exit()
}

const ssh = new NodeSSH()
try {
  console.log('Attempting to connect to droplet via SSH, ip:', dropletIP)
  await ssh.connect({
    host: dropletIP,
    username: 'root',
    privateKeyPath: '/Users/david/.ssh/id_ed25519'
  })
  console.log('✅  Connected to droplet via SSH connected')
} catch (error) {
  console.error('Error connecting to new droplet via SSH', error.message)
  process.exit()
}

try {
  const sessionUser = await ssh.exec('whoami', [], {
    cwd: '/root/',
    stream: 'stdout',
    options: { pty: true }
  })
  console.log('✅  Executed command on droplet as', sessionUser)

  const output = await ssh.exec('git clone', ['https://github.com/neighbourhoodie/couchdb-minihosting.git'], {
    cwd: '/root/',
    onStdout(chunk) {
      console.log('stdoutChunk', chunk.toString('utf8'))
    },
    onStderr(chunk) {
      console.log('stderrChunk', chunk.toString('utf8'))
    },
    options: { pty: true }
  })
  console.log('✅  Repository cloned', output)
} catch (error) {
  console.error('❌  Error executing command on droplet', error.message)
  process.exit()
}

process.exit()

