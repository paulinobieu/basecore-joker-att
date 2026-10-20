import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import JobTip from './components/JobTip'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <App />
        <JobTip />
    </React.StrictMode>,
)
