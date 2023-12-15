import styled from '@emotion/styled'
import React from 'react'
import DarkModeToggle from './components/DarkModeToggle'
import { AppShell, Button, Card, Flex, SimpleGrid, Text } from '@mantine/core'
import { useAtomValue } from 'jotai'
import { usersAtom } from './state'
// import { Header, Navbar } from '@mantine/core'

const Container = styled.div`
  margin: 0 auto;
  padding: 36px 0;
  width: 90%;
`

const User = () => {
  return (
    <AppShell header={{ height: 60 }}>
      <AppShell.Header p={8}>
        <Flex align="center" justify="space-between">
          <Text size="xl">Dashboard</Text>
          <DarkModeToggle />
        </Flex>
      </AppShell.Header>
      <AppShell.Main>
        <Users />
      </AppShell.Main>
    </AppShell>
  )
}

export default App
