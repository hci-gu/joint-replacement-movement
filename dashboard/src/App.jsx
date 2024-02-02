import styled from '@emotion/styled'
import React from 'react'
import DarkModeToggle from './components/DarkModeToggle'
import {
  Anchor,
  AppShell,
  Button,
  Card,
  Flex,
  SimpleGrid,
  Text,
} from '@mantine/core'
import { useAtomValue } from 'jotai'
import { dataTypes, usersAtom } from './state'
import { Route, useLocation } from 'wouter'
import User from './User'
// import { Header, Navbar } from '@mantine/core'

const Container = styled.div`
  margin: 0 auto;
  padding: 36px 0;
  width: 90%;
`

const _formatDate = (dateString) =>
  dateString ? dateString.split('T')[0] : 'N/A'

const _formatTitle = (title) => {
  const words = title.split('_')
  return words
    .map((w) => w[0].toUpperCase() + w.slice(1).toLowerCase())
    .join(' ')
}

const Users = () => {
  const users = useAtomValue(usersAtom)

  return (
    <Container>
      <SimpleGrid cols={2}>
        {users.map((u) => (
          <Card
            key={`User_${u.personal_id}`}
            shadow="sm"
            padding="xl"
            radius="md"
            withBorder
          >
            <Card.Section inheritPadding withBorder p="sm">
              <Anchor
                href={`/user/${u.id}`}
                fw={500}
                size="xl"
                underline="always"
              >
                {u.personal_id}
              </Anchor>
            </Card.Section>
            {dataTypes.map((k) => (
              <Flex align="baseline" justify="space-between">
                <Text fw={500} size="lg" mt="md">
                  {_formatTitle(k)}:
                </Text>
                <Text size="lg" mt="md" c="dimmed">
                  {_formatDate(u[k].first)} - {_formatDate(u[k].last)}
                </Text>
              </Flex>
            ))}
          </Card>
        ))}
      </SimpleGrid>
    </Container>
  )
}

const App = () => {
  return (
    <AppShell header={{ height: 60 }}>
      <AppShell.Header p={12}>
        <Flex align="center" justify="space-between">
          <Text size="xl" fw={500}>
            Dashboard
          </Text>
          <DarkModeToggle />
        </Flex>
      </AppShell.Header>
      <AppShell.Main>
        <Route path="/">
          <Users />
        </Route>
        <Route path="/user/:id">
          <User />
        </Route>
      </AppShell.Main>
    </AppShell>
  )
}

export default App
