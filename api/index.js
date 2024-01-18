require('dotenv').config()
const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const { Pool } = require('pg')

const app = express()
app.use(cors())
const port = 4000

const API_KEY = process.env.API_KEY

const authMiddleware = (req, res, next) => {
  const { authorization } = req.headers
  if (authorization !== API_KEY) {
    res.status(401).send('Unauthorized')
    return
  }
  next()
}

const tables = [
  'steps',
  'walking_speed',
  'walking_asymmetry_percentage',
  'walking_steadiness',
  'walking_double_support_percentage',
  'walking_step_length',
]

const { DB_USERNAME, DB_HOST, DB, DB_PASSWORD } = process.env
const [db_host, db_port] = DB_HOST?.split(':') ?? ['localhost', '5678']

// PostgreSQL connection setup
console.log({
  user: DB_USERNAME,
  host: db_host,
  database: DB,
  password: DB_PASSWORD,
  port: db_port,
})
const pool = new Pool({
  user: DB_USERNAME,
  host: db_host,
  database: DB,
  password: DB_PASSWORD,
  port: db_port,
})

// bodyparser and allow max size
app.use(bodyParser.json({ limit: '500mb' }))

async function processInBatches(table, personalId, data, batchSize) {
  for (let i = 0; i < data.length; i += batchSize) {
    const batch = data.slice(i, i + batchSize)
    await batchInsert(table, personalId, batch)
  }
}

async function batchInsert(table, personalId, data) {
  const values = []
  const placeholders = []

  let placeholderIndex = 1
  data.forEach((item) => {
    values.push(
      personalId,
      table == 'steps'
        ? parseInt(item.value.numericValue)
        : parseFloat(item.value.numericValue),
      item.data_type,
      item.unit,
      item.date_from,
      item.date_to,
      item.platform_type,
      item.device_id,
      item.source_id,
      item.source_name
    )
    placeholders.push(
      `($${placeholderIndex}, $${placeholderIndex + 1}, $${
        placeholderIndex + 2
      }, $${placeholderIndex + 3}, $${placeholderIndex + 4}, $${
        placeholderIndex + 5
      }, $${placeholderIndex + 6}, $${placeholderIndex + 7}, $${
        placeholderIndex + 8
      }, $${placeholderIndex + 9})`
    )
    placeholderIndex += 10 // Increment by the number of fields per record
  })

  const queryText = `
    INSERT INTO ${table} 
        (personal_id, value, data_type, unit, date_from, date_to, platform_type, device_id, source_id, source_name) 
    VALUES 
        ${placeholders.join(', ')}
    RETURNING *;
  `

  return pool.query(queryText, values.flat())
}

const checkIfUserExists = async (personalId) => {
  const queryText = `SELECT COUNT(*) FROM steps WHERE personal_id = $1`
  const { rows } = await pool.query(queryText, [personalId])
  const count = rows[0].count

  return count > 0
}

// POST route to receive and save data
app.post('/data', async (req, res) => {
  try {
    const { data, personalId } = req.body

    // Check if user exists
    const userExists = await checkIfUserExists(personalId)
    if (userExists) {
      res.status(200)
      return
    }

    // Sort data into groups based on data_type
    const dataGroups = data.reduce((acc, item) => {
      const dataType = item.data_type.toLowerCase()
      acc[dataType] = acc[dataType] || []
      acc[dataType].push(item)
      return acc
    }, {})

    // Perform batch inserts for each group

    for (const [dataType, items] of Object.entries(dataGroups)) {
      await processInBatches(dataType, personalId, items, 5000)
    }

    res.sendStatus(200)
  } catch (error) {
    console.error('Error saving data', error)
    res.status(500).send('Error saving data')
  }
})

app.get('/users', authMiddleware, async (req, res) => {
  let users = {}
  for (const table of tables) {
    const queryText = `SELECT DISTINCT personal_id FROM ${table}`
    const { rows } = await pool.query(queryText)

    for (const row of rows) {
      // get count of data points for each user
      const countQueryText = `SELECT COUNT(*) FROM ${table} WHERE personal_id = $1`
      const { rows: countRows } = await pool.query(countQueryText, [
        row.personal_id,
      ])
      const count = countRows[0].count

      // get first and last data point for each user
      const firstQueryText = `SELECT * FROM ${table} WHERE personal_id = $1 ORDER BY date_from ASC LIMIT 1`
      const { rows: firstRows } = await pool.query(firstQueryText, [
        row.personal_id,
      ])
      const first = firstRows[0]

      const lastQueryText = `SELECT * FROM ${table} WHERE personal_id = $1 ORDER BY date_from DESC LIMIT 1`
      const { rows: lastRows } = await pool.query(lastQueryText, [
        row.personal_id,
      ])
      const last = lastRows[0]

      users[row.personal_id] = {
        ...users[row.personal_id],
        [table]: {
          count: parseInt(count),
          first: first.date_from,
          last: last.date_to,
        },
      }
    }
    //
  }
  // conver to array
  users = Object.entries(users).map(([personalId, data]) => ({
    personalId,
    ...data,
  }))

  res.send(users)
})

app.get('/:type', authMiddleware, async (req, res) => {
  try {
    const { type } = req.params

    // verify type is one of the allowed types
    if (!tables.includes(type)) {
      res.status(400).send('Invalid type')
      return
    }

    const queryText = `SELECT * FROM ${type}`
    const { rows } = await pool.query(queryText)

    res.send(rows)
  } catch (error) {
    console.error('Error getting data', error)
    res.status(500).send('Error getting data')
  }
})

app.get('/:type/:personalId', authMiddleware, async (req, res) => {
  try {
    const { type, personalId } = req.params
    console.log(type, personalId)

    // verify type is one of the allowed types
    if (!tables.includes(type)) {
      res.status(400).send('Invalid type')
      return
    }

    const queryText = `SELECT * FROM ${type} WHERE personal_id = $1`
    const { rows } = await pool.query(queryText, [personalId])

    res.send(rows)
  } catch (error) {
    console.error('Error getting data', error)
    res.status(500).send('Error getting data')
  }
})

app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`)
})
