import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import App from './App'

test('initial count is 0', () => {
  render(<App />)
  expect(screen.getByTestId('count')).toHaveTextContent('0')
})

test('clicking the button increments count to 1', async () => {
  const user = userEvent.setup()
  render(<App />)
  await user.click(screen.getByRole('button', { name: /count up/i }))
  expect(screen.getByTestId('count')).toHaveTextContent('1')
})

test('clicking the button multiple times accumulates count', async () => {
  const user = userEvent.setup()
  render(<App />)
  const button = screen.getByRole('button', { name: /count up/i })
  await user.click(button)
  await user.click(button)
  await user.click(button)
  expect(screen.getByTestId('count')).toHaveTextContent('3')
})

test('no reset or decrement button exists', () => {
  render(<App />)
  const buttons = screen.getAllByRole('button')
  expect(buttons).toHaveLength(1)
})
