import { useState } from 'react';
import './App.css';

function App() {
  const [count, setCount] = useState(0);

  return (
    <main>
      <h1 className="count" aria-live="polite">{count}</h1>
      <button onClick={() => setCount((c) => c + 1)}>Increment</button>
    </main>
  );
}

export default App;
