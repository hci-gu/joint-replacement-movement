import { atom } from 'jotai'
import axios from 'axios'
import { atomWithDefault } from 'jotai/utils'

const API_URL = 'https://jr-movement-api.prod.appadem.in'

export const usersAtom = atomWithDefault(async (get, { signal }) => {
  const response = await axios.get(`${API_URL}/users`, { signal })

  return response.data
})
