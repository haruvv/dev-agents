import { useState } from 'react'
import './App.css'

export default function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="container">
      <h1>Counter</h1>
      <p data-testid="count" className="count">{count}</p>
      <button className="count-button" onClick={() => setCount(c => c + 1)}>Count up</button>
    </div>
  )
}
