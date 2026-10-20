import { useState, useEffect, useCallback } from 'react'
import Timer from './components/Timer'
import Killfeed from './components/Killfeed'
import DevPanel from './components/DevPanel'
import './App.css'

const isDev = !window.invokeNative && import.meta.env.DEV

function App() {
  const [visible, setVisible] = useState(isDev)
  const [timer, setTimer] = useState('')
  const [showTimer, setShowTimer] = useState(false)
  const [kills, setKills] = useState([])

  const handleMessage = useCallback((event) => {
    const data = event.data

    switch (data.action) {
      case 'showMenu':
        setVisible(true)
        break

      case 'hideMenu':
        setVisible(false)
        break

      case 'hide':
        setVisible(false)
        setShowTimer(false)
        setKills([])
        break

      case 'timer':
        setVisible(true)
        setShowTimer(true)
        setTimer(data.timer)
        break

      case 'timer2':
        setVisible(true)
        setShowTimer(true)
        setTimer(data.timer)
        break

      case 'novakill': {
        setVisible(true)
        const kill = {
          id: Date.now() + Math.random(),
          matador: data.matador,
          morto: data.morto,
          arma: data.arma,
        }
        setKills((prev) => [...prev, kill])

        setTimeout(() => {
          setKills((prev) => prev.filter((k) => k.id !== kill.id))
        }, 7000)
        break
      }

      default:
        break
    }
  }, [])

  useEffect(() => {
    window.addEventListener('message', handleMessage)
    return () => window.removeEventListener('message', handleMessage)
  }, [handleMessage])

  useEffect(() => {
    if (isDev) document.body.classList.add('dev-mode')
    return () => document.body.classList.remove('dev-mode')
  }, [])

  return (
    <>
      {isDev && <DevPanel />}
      {visible && (
        <div className="hud-container">
          {showTimer && <Timer time={timer} />}
          <Killfeed kills={kills} />
        </div>
      )}
    </>
  )
}

export default App
