import { useState } from 'react';

export default function App() {
  const [showMessage, setShowMessage] = useState(false);

  return (
    <div>
      <button onClick={() => setShowMessage(true)}>ボタン</button>
      {showMessage && <p>GO!</p>}
    </div>
  );
}
