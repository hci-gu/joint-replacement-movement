import '@mantine/core/styles.css'
import '@mantine/dates/styles.css'
import React, { useState } from 'react'
import ReactDOM from 'react-dom/client'
import { MantineProvider } from '@mantine/core'
import App from './App'
import { Router } from 'wouter'

const Root = () => {
  const [colorScheme, setColorScheme] = useState('light')
  const toggleColorScheme = (value) =>
    setColorScheme(value || (colorScheme === 'dark' ? 'light' : 'dark'))

  return (
    <MantineProvider defaultColorScheme={colorScheme}>
      <Router>
        <App />
      </Router>
    </MantineProvider>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <Root />
  </React.StrictMode>
)
