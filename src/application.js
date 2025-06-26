import React from 'react';
import ReactDOM from 'react-dom/client';
import HelloWorld from './HelloWorld';

document.addEventListener('DOMContentLoaded', () => {
  const root = ReactDOM.createRoot(document.getElementById('react-root'));
  root.render(<HelloWorld />);
});
