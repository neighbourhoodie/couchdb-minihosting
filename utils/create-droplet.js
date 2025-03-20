import dotenv from 'dotenv'
import inquirer from 'inquirer'
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

// curl -X GET \
//   -H "Content-Type: application/json" \
//   -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
//   "https://api.digitalocean.com/v2/droplets?page=1&per_page=1"

try {
  const { data } = await axios.get(`${digitalOceanApiUrl}/droplets?page=1&per_page=10`, digitalOceanRequestConfig)
  console.log('✅  Retrieved droplets', data.droplets.map(droplet => droplet.name))
  const selectedDroplet = await inquirer.prompt(['Select droplet to connect to'])
} catch (error) {
  console.error('Error retrieving droplets', error.response?.data)
  process.exit()
}


const ssh = new NodeSSH()
try {
  await ssh.connect({
    host: process.env.HOST,
    username: 'root',
    privateKeyPath: '/Users/david/.ssh/id_ed25519'
  })
  console.log('✅  Connected to droplet via SSH connected')
} catch (error) {
  console.error('Error connecting to new droplet via SSH', error.message)
  process.exit()
}

try {
  const output = await ssh.exec('whoami', [], {
    cwd: '/root/',
    stream: 'stdout',
    options: { pty: true }
  })
  console.log('✅  Executed command on droplet as', output)
} catch (error) {
  console.error('❌  Error executing command on droplet', error.message)
  process.exit()
}

try {
  const output = await ssh.exec('whoami', [], {
    cwd: '/root/',
    stream: 'stdout',
    options: { pty: true }
  })
  console.log('✅  git', output)
} catch (error) {
  console.error('❌  Error executing command on droplet', error.message)
  process.exit()
}


process.exit()

