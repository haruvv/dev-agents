import { render, screen, fireEvent } from '@testing-library/react';
import App from './App.jsx';

test('renders initial count of 0', () => {
  render(<App />);
  expect(screen.getByRole('heading')).toHaveTextContent('0');
});

test('increments count on button click', () => {
  render(<App />);
  const button = screen.getByRole('button', { name: /increment/i });
  fireEvent.click(button);
  expect(screen.getByRole('heading')).toHaveTextContent('1');
});

test('increments count multiple times', () => {
  render(<App />);
  const button = screen.getByRole('button', { name: /increment/i });
  fireEvent.click(button);
  fireEvent.click(button);
  fireEvent.click(button);
  expect(screen.getByRole('heading')).toHaveTextContent('3');
});
