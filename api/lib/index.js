require('dotenv').config()
const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const DB = require('./db')

const app = express()
app.use(cors())
const port = 4000

const API_KEY = process.env.API_KEY

const authMiddleware = (req, res, next) => {
  // const { authorization } = req.headers
  // if (authorization !== API_KEY) {
  //   res.status(401).send('Unauthorized')
  //   return
  // }
  next()
}

// bodyparser and allow max size
app.use(bodyParser.json({ limit: '750mb' }))

// POST route to receive and save data
app.post('/data', async (req, res) => {
  try {
    const { data, personalId, eventDate } = req.body
    console.log('Received data for user', personalId, eventDate)

    // Check if user exists
    let user = await DB.getUser(personalId)
    if (user) {
      res.status(200)
      return
    } else {
      user = await DB.createUser(personalId, eventDate)
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
      await DB.processInBatches(dataType, user.id, items, 5000)
    }

    res.sendStatus(200)
  } catch (error) {
    console.error('Error saving data', error)
    res.status(500).send('Error saving data')
  }
})

app.get('/users', authMiddleware, async (req, res) => {
  try {
    const rows = await DB.getUsers()

    res.send(rows)
  } catch (error) {
    console.error('Error getting users', error)
    res.status(500).send('Error getting users')
  }
})

app.get('/:type/:id', authMiddleware, async (req, res) => {
  try {
    const { type, id } = req.params

    // verify type is one of the allowed types
    if (!DB.TABLES.includes(type)) {
      res.status(400).send('Invalid type')
      return
    }
    const rows = await DB.getDataForType(type, id)

    res.send(rows)
  } catch (error) {
    console.error('Error getting data', error)
    res.status(500).send('Error getting data')
  }
})

app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`)
})