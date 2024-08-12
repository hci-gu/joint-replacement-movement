import { atom } from 'jotai'
import { atomFamily, atomWithDefault } from 'jotai/utils'
import deepEqual from 'fast-deep-equal'
import PocketBase from 'pocketbase'

console.log(import.meta.env.VITE_API_URL)
const pb = new PocketBase(import.meta.env.VITE_API_URL)

pb.admins.authWithPassword(
  import.meta.env.VITE_ADMIN_USERNAME,
  import.meta.env.VITE_ADMIN_PASSWORD
)

export const dataTypes = [
  'steps',
  'walking_speed',
  'walking_asymmetry_percentage',
  'walking_steadiness',
  'walking_double_support_percentage',
  'walking_step_length',
]

const answersObjectForAnswers = (answers, questionnaires) => {
  const dailyQuestionnaire = questionnaires.find((q) => q.occurance === 'daily')
  const weeklyQuestionnaire = questionnaires.find(
    (q) => q.occurance === 'weekly'
  )
  const dailyAnswers = answers.filter(
    (a) => a.questionnaire === dailyQuestionnaire.id
  )
  dailyAnswers.sort((a, b) => a.date.localeCompare(b.date))

  const weeklyAnswers = answers.filter(
    (a) => a.questionnaire === weeklyQuestionnaire.id
  )
  weeklyAnswers.sort((a, b) => a.date.localeCompare(b.date))

  const firstDailyAnswer = dailyAnswers[0]

  const firstDate = new Date(firstDailyAnswer.date)
  const today = new Date()
  const days = Math.round((today - firstDate) / (1000 * 3600 * 24))
  const weeks = Math.round(days / 7)

  const answersObject = {
    started: firstDate,
    days,
    weeks,
    daily: dailyAnswers,
    weekly: weeklyAnswers,
  }
  return answersObject
}

export const usersAtom = atomWithDefault(async (get, { signal }) => {
  const questionnaires = await pb
    .collection('questionnaires')
    .getFullList({ signal })
  const users = await pb.collection('users').getFullList({ signal })

  for (const user of users) {
    const answers = await pb
      .collection('answers')
      .getFullList({ signal, filter: `user = "${user.id}"` })
    user.answers = answersObjectForAnswers(answers, questionnaires)

    for (const dataType of dataTypes) {
      const first = await pb.collection(dataType).getList(0, 1, {
        filter: `user = "${user.id}"`,
        sort: 'date_from',
      })
      const last = await pb.collection(dataType).getList(0, 1, {
        filter: `user = "${user.id}"`,
        sort: '-date_from',
      })

      user[dataType] = {
        first: first.items[0]?.date_from?.substring(0, 10),
        last: last.items[0]?.date_from.substring(0, 10),
      }
    }
  }

  return users
})

export const groupByAtom = atom('day')
export const dateRangeAtom = atom([null, new Date()])

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

const groupDataByInterval = (data, interval, dateRange) => {
  if (!data.length) return []

  const minDate = dateRange ? dateRange[0] : new Date(data[0].date)
  const maxDate = dateRange
    ? dateRange[1]
    : new Date(data[data.length - 1].date)
  const days = Math.round(
    (maxDate.getTime() - minDate.getTime()) / (1000 * 3600 * 24)
  )

  const daysData = {}
  for (let i = 0; i < days; i++) {
    const date = new Date(minDate.getTime())
    date.setDate(date.getDate() + i)
    daysData[formatDate(date, 'day')] = 0
  }

  data.forEach((item) => {
    const dateKey = formatDate(item.date, 'day')
    if (!daysData[dateKey]) daysData[dateKey] = 0
    daysData[dateKey] += item.value
  })
  if (interval === 'day') {
    return Object.keys(daysData).map((key) => {
      return {
        date: key,
        value: daysData[key] == 0 ? null : daysData[key],
        sort: new Date(key).valueOf(),
      }
    })
  }

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

const groupStepsByInterval = (data, interval, dateRange) => {
  const minDate = dateRange ? dateRange[0] : new Date(data[0].date)
  const maxDate = dateRange
    ? dateRange[1]
    : new Date(data[data.length - 1].date)

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
      const response = await pb
        .collection(type)
        .getFullList({ filter: `user = "${id}"` })

      return response
    }),
  deepEqual
)

export const stepsAtom = atomFamily(
  (id) =>
    atom(async (get) => {
      const data = await get(dataAtom({ id, type: 'steps' }))
      const groupBy = get(groupByAtom)
      const [from, to] = get(dateRangeAtom)

      const mappedData = data.reverse().map((d) => ({
        value: parseFloat(d.value),
        date: new Date(d.date_from),
        device: d.device_id,
      }))

      const filteredData =
        from && to
          ? mappedData.filter((d) => d.date >= from && d.date <= to)
          : mappedData

      const grouped = groupStepsByInterval(
        filteredData,
        groupBy,
        from && to ? [from, to] : null
      )

      return grouped.sort((a, b) => a.sort - b.sort)
    }),
  deepEqual
)

export const formattedDataAtom = atomFamily(
  ({ id, type }) =>
    atom(async (get) => {
      if (type == 'steps') return get(stepsAtom(id))
      const data = await get(dataAtom({ id, type }))
      const groupBy = get(groupByAtom)
      const [from, to] = get(dateRangeAtom)

      const mappedData = data.reverse().map((d) => ({
        value: parseFloat(d.value),
        date: new Date(d.date_from),
        device: d.device_id,
      }))

      const filteredData =
        from && to
          ? mappedData.filter((d) => d.date >= from && d.date <= to)
          : mappedData

      const grouped = groupDataByInterval(
        filteredData,
        groupBy,
        from && to ? [from, to] : null
      )

      return grouped.sort((a, b) => a.sort - b.sort)
    }),
  deepEqual
)
