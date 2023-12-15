import '@mantine/core/styles.css'
import React, { useState } from 'react'
import ReactDOM from 'react-dom/client'
import { MantineProvider } from '@mantine/core'
import App from './App'

const Root = () => {
  const [colorScheme, setColorScheme] = useState('light')
  const toggleColorScheme = (value) =>
    setColorScheme(value || (colorScheme === 'dark' ? 'light' : 'dark'))

  return (
    <MantineProvider defaultColorScheme={colorScheme}>
      <App />
    </MantineProvider>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <Root />
  </React.StrictMode>
)
