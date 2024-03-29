import styled from '@emotion/styled'
import React, { Suspense } from 'react'
import DarkModeToggle from './components/DarkModeToggle'
import {
  Anchor,
  AppShell,
  Breadcrumbs,
  Button,
  Card,
  Center,
  Collapse,
  Flex,
  Loader,
  SegmentedControl,
  SimpleGrid,
  Space,
  Text,
} from '@mantine/core'
import { useAtom, useAtomValue } from 'jotai'
import {
  dataAtom,
  dateRangeAtom,
  formattedDataAtom,
  groupByAtom,
  stepsAtom,
  usersAtom,
} from './state'
import { Route, Router, useParams } from 'wouter'
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { suspend } from 'suspend-react'
import { DateInput } from '@mantine/dates'
// import { Header, Navbar } from '@mantine/core'

const Container = styled.div`
  margin: 0 auto;
  padding: 36px 0;
  width: 90%;
`

const types = [
  { name: 'steps' },
  { name: 'walking_speed' },
  { name: 'walking_asymmetry_percentage' },
  { name: 'walking_steadiness' },
  { name: 'walking_step_length' },
  { name: 'walking_double_support_percentage' },
]

const Chart = ({ type, id }) => {
  const data = useAtomValue(
    formattedDataAtom({
      id,
      type,
    })
  )

  return (
    <ResponsiveContainer height={200} style={{ marginTop: 16 }}>
      <LineChart width={'100%'} height={'100%'} data={data}>
        <XAxis dataKey="date" />
        <YAxis />
        <Line type="monotone" dataKey="value" stroke="#8884d8" dot={false} />
        <Tooltip />
      </LineChart>
    </ResponsiveContainer>
  )
}

const DataType = ({ type, id }) => {
  return (
    <Card shadow="sm" padding="xl" radius="md" withBorder>
      <Card.Section inheritPadding withBorder p="sm">
        <Text size="xl">{type}</Text>
      </Card.Section>
      <Suspense
        fallback={
          <Center h={200}>
            <Loader />
          </Center>
        }
      >
        <Chart type={type} id={id} />
      </Suspense>
    </Card>
  )
}

const GroupBySelect = () => {
  const [groupBy, setGroupBy] = useAtom(groupByAtom)

  return (
    <SegmentedControl
      h={40}
      data={['day', 'week', 'month', 'year']}
      value={groupBy}
      onChange={setGroupBy}
    />
  )
}

const DateRangeSelect = () => {
  const [dateRange, setDateRange] = useAtom(dateRangeAtom)

  const onChange = (value, index) => {
    setDateRange((prev) => {
      const next = [...prev]
      next[index] = value
      return next
    })
  }

  return (
    <Flex gap="sm">
      <DateInput
        value={dateRange[0]}
        onChange={(val) => onChange(val, 0)}
        label="From"
        placeholder="Select date"
      />
      <DateInput
        value={dateRange[1]}
        onChange={(val) => onChange(val, 1)}
        label="To"
        placeholder="Select date"
      />
    </Flex>
  )
}

const User = () => {
  const { id } = useParams()

  return (
    <Container>
      <Flex justify="space-between">
        <Breadcrumbs>
          <Anchor href="/">Home</Anchor>
          <Anchor href={`/user/${id}`}>{id}</Anchor>
        </Breadcrumbs>
        <Flex gap="sm" justify="center" align="end">
          <DateRangeSelect />
          <GroupBySelect />
        </Flex>
      </Flex>
      <Space h="lg" />
      <SimpleGrid cols={1}>
        {types.map((t) => (
          <DataType key={`Type_${t.name}`} type={t.name} id={id} />
        ))}
      </SimpleGrid>
    </Container>
  )
}

export default User
