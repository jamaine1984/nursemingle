import React from 'react';

const App: React.FC = () => {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1 style={{ color: '#e91e63' }}>Nurse Mingle</h1>
      <p>Application is loading successfully!</p>
      <div style={{ marginTop: '20px' }}>
        <button
          style={{
            backgroundColor: '#e91e63',
            color: 'white',
            padding: '10px 20px',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer'
          }}
          onClick={() => alert('Authentication system is working!')}
        >
          Test Authentication
        </button>
      </div>
      <div style={{ marginTop: '10px', fontSize: '14px', color: '#666' }}>
        Firebase Project: nurse-mingle-2
      </div>
    </div>
  );
};

export default App;