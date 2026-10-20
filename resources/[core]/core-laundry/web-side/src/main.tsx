import React from 'react'
import ReactDOM from 'react-dom/client'
import { Layout } from '@views/layout'
import '@views/styles/index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <Layout />
    </React.StrictMode>,
)
