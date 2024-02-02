const { Pool } = require('pg')

const TABLES = [
  'users',
  'steps',
  'walking_speed',
  'walking_asymmetry_percentage',
  'walking_steadiness',
  'walking_double_support_percentage',
  'walking_step_length',
]
const DATA_TABLES = TABLES.filter((table) => table !== 'users')

const { DB_USERNAME, DB_HOST, DB, DB_PASSWORD } = process.env
const [db_host, db_port] = DB_HOST?.split(':') ?? ['localhost', '5432']
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

async function batchInsert(table, userId, data) {
  const values = []
  const placeholders = []

  let placeholderIndex = 1
  data.forEach((item) => {
    values.push(
      userId,
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
            (user_id, value, data_type, unit, date_from, date_to, platform_type, device_id, source_id, source_name) 
        VALUES 
            ${placeholders.join(', ')}
        RETURNING *;
      `

  return pool.query(queryText, values.flat())
}

async function processInBatches(table, userId, data, batchSize) {
  for (let i = 0; i < data.length; i += batchSize) {
    const batch = data.slice(i, i + batchSize)
    await batchInsert(table, userId, batch)
  }
}

const getUser = async (personalId) => {
  const queryText = `SELECT * FROM users WHERE personal_id = $1`
  const { rows } = await pool.query(queryText, [personalId])
  return rows[0]
}

const getUsers = async () => {
  const queryText = `SELECT * FROM users`
  const { rows } = await pool.query(queryText)
  return rows
}

const createUser = async (personalId, event_date) => {
  const queryText = `INSERT INTO users (personal_id, event_date, created_at) VALUES ($1, $2, $3) RETURNING *`
  const { rows } = await pool.query(queryText, [
    personalId,
    event_date,
    new Date(),
  ])
  return rows[0]
}

const getDataForType = async (type, id) => {
  const queryText = `SELECT * FROM ${type} WHERE user_id = $1`
  const { rows } = await pool.query(queryText, [id])

  return rows
}

const getUserMetadata = async (id) => {
  let info = DATA_TABLES.reduce((acc, table) => {
    acc[table] = { count: 0, first: null, last: null }
    return acc
  }, {})
  for (table of DATA_TABLES) {
    // get count of data points for each user
    const countQueryText = `SELECT COUNT(*) FROM ${table} WHERE user_id = $1`
    const { rows: countRows } = await pool.query(countQueryText, [id])
    info[table].count = countRows[0].count

    // get first and last data point for each user
    const firstQueryText = `SELECT * FROM ${table} WHERE user_id = $1 ORDER BY date_from ASC LIMIT 1`
    const { rows: firstRows } = await pool.query(firstQueryText, [id])
    info[table].first = firstRows[0]?.date_from

    const lastQueryText = `SELECT * FROM ${table} WHERE user_id = $1 ORDER BY date_from DESC LIMIT 1`
    const { rows: lastRows } = await pool.query(lastQueryText, [id])
    info[table].last = lastRows[0]?.date_from
  }
  return info
}

const saveForm = (userId, name, answers) => {
  const queryText = `INSERT INTO questionnaires (user_id, name, created_at, answers) VALUES ($1, $2, $3, $4) RETURNING *`
  return pool.query(queryText, [userId, name, new Date(), answers])
}

module.exports = {
  processInBatches,
  getUser,
  getUsers,
  createUser,
  getDataForType,
  getUserMetadata,
  saveForm,
  TABLES,
}
