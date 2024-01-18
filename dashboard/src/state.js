import { atom } from 'jotai'
import axios from 'axios'
import { atomFamily, atomWithDefault } from 'jotai/utils'
import deepEqual from 'fast-deep-equal'

const API_URL = 'https://jr-movement-api.prod.appadem.in'
const API_KEY = import.meta.env.VITE_API_KEY

export const usersAtom = atomWithDefault(async (get, { signal }) => {
  const response = await axios.get(`${API_URL}/users`, {
    signal,
    headers: { authorization: API_KEY },
  })

  return response.data
})

export const groupByAtom = atom('day')

const pad = (n) => (n < 10 ? `0${n}` : n)

const formatDate = (date, interval) => {
  // Format your date as needed, e.g., 'YYYY-MM-DD'
  switch (interval) {
    case 'week':
      const week = new Date(date.getTime())
      week.setDate(week.getDate() - week.getDay())
      return `${week.getFullYear()}-${pad(week.getMonth() + 1)}-${pad(
        week.getDate()
      )}`
    case 'month':
      return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-01`
    case 'year':
      return `${date.getFullYear()}-01-01`
    case 'day':
    default:
      return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(
        date.getDate()
      )}`
  }
}

const groupDataByInterval = (data, interval) => {
  const groupedData = {}

  // Group data by interval
  data.forEach((item) => {
    const dateKey = formatDate(item.date, interval) // Adjust this for weekly, monthly, etc.
    if (!groupedData[dateKey]) {
      groupedData[dateKey] = { total: 0, count: 0 }
    }
    groupedData[dateKey].total += item.value
    groupedData[dateKey].count += 1
  })

  // Calculate average
  return Object.keys(groupedData).map((key) => {
    const avg = groupedData[key].total / groupedData[key].count
    return { date: key, value: avg, sort: new Date(key).valueOf() }
  })
}

const groupStepsByInterval = (data, interval) => {
  const minDate = new Date(data[0].date)
  const maxDate = new Date(data[data.length - 1].date)

  const days = Math.round(
    (maxDate.getTime() - minDate.getTime()) / (1000 * 3600 * 24)
  )

  const daysData = {}
  for (let i = 0; i < days; i++) {
    const date = new Date(minDate.getTime())
    date.setDate(date.getDate() + i)
    daysData[formatDate(date, 'day')] = 0
  }

  // total steps per day
  data.forEach((item) => {
    const dateKey = formatDate(item.date, 'day')
    if (!daysData[dateKey]) daysData[dateKey] = 0
    daysData[dateKey] += item.value
  })

  if (interval === 'day') {
    return Object.keys(daysData).map((key) => {
      return { date: key, value: daysData[key], sort: new Date(key).valueOf() }
    })
  }

  const groupedData = {}

  // Group data by interval
  Object.keys(daysData).forEach((key) => {
    const date = new Date(key)
    const dateKey = formatDate(date, interval) // Adjust this for weekly, monthly, etc.

    if (!groupedData[dateKey]) {
      groupedData[dateKey] = { total: 0, count: 0 }
    }
    groupedData[dateKey].total += daysData[key]
    groupedData[dateKey].count += 1
  })

  // Calculate average
  return Object.keys(groupedData).map((key) => {
    const avg = groupedData[key].total / groupedData[key].count
    return { date: key, value: avg, sort: new Date(key).valueOf() }
  })
}

export const dataAtom = atomFamily(
  ({ id, type }) =>
    atom(async (get) => {
      const response = await axios.get(`${API_URL}/${type}/${id}`, {
        headers: { authorization: API_KEY },
      })
      return response.data
    }),
  deepEqual
)

export const stepsAtom = atomFamily(
  (id) =>
    atom(async (get) => {
      const data = await get(dataAtom({ id, type: 'steps' }))
      const groupBy = get(groupByAtom)

      return groupStepsByInterval(
        data.reverse().map((d) => ({
          value: parseFloat(d.value),
          date: new Date(d.date_from),
        })),
        groupBy
      )
    }),
  deepEqual
)

export const formattedDataAtom = atomFamily(
  ({ id, type }) =>
    atom(async (get) => {
      if (type == 'steps') return get(stepsAtom(id))

      const data = await get(dataAtom({ id, type }))
      const groupBy = get(groupByAtom)
      const grouped = groupDataByInterval(
        data.reverse().map((d) => ({
          value: parseFloat(d.value),
          date: new Date(d.date_from),
        })),
        groupBy
      )

      return grouped.sort((a, b) => a.sort - b.sort)
    }),
  deepEqual
)
