// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

import React from 'react'
import ReactDOM from 'react-dom/client'
import { App } from './components/App'

const dom = document.getElementById('root')
const data = dom.getAttribute('data-parent') || 'bun'

ReactDOM.createRoot(dom).render(
    <React.StrictMode>
        <App name={data} />
    </React.StrictMode>
)