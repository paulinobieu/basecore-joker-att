import { useCallback } from 'react'
import './DevPanel.css'

const WEAPONS = [
  'weapon_assaultrifle', 'weapon_carbinerifle', 'weapon_smg', 'weapon_pistol',
  'weapon_combatpdw', 'weapon_microsmg', 'weapon_pumpshotgun', 'weapon_sniperrifle',
  'weapon_heavysniper', 'weapon_minigun', 'weapon_rpg', 'weapon_bat',
]

const NAMES = ['Raven', 'Specter', 'Outlaw', 'Nomad', 'Warden', 'Ghost', 'Viper', 'Ace']

function randomFrom(arr) {
  return arr[Math.floor(Math.random() * arr.length)]
}

function send(action, payload = {}) {
  window.postMessage({ action, ...payload }, '*')
}

function DevPanel() {
  const showMenu = useCallback(() => send('showMenu'), [])
  const hideMenu = useCallback(() => send('hideMenu'), [])
  const hideAll = useCallback(() => send('hide'), [])

  const startTimer = useCallback(() => {
    send('timer', { timer: '30:00' })
  }, [])

  const updateTimer = useCallback(() => {
    send('timer2', { timer: '29:' + String(Math.floor(Math.random() * 60)).padStart(2, '0') })
  }, [])

  const addKill = useCallback(() => {
    send('novakill', {
      matador: randomFrom(NAMES),
      morto: randomFrom(NAMES),
      arma: randomFrom(WEAPONS),
    })
  }, [])

  const addKillBurst = useCallback(() => {
    for (let i = 0; i < 3; i++) {
      setTimeout(() => {
        send('novakill', {
          matador: randomFrom(NAMES),
          morto: randomFrom(NAMES),
          arma: randomFrom(WEAPONS),
        })
      }, i * 300)
    }
  }, [])

  const demoFull = useCallback(() => {
    send('showMenu')
    setTimeout(() => send('timer', { timer: '30:00' }), 200)
    for (let i = 0; i < 4; i++) {
      setTimeout(() => {
        send('novakill', {
          matador: randomFrom(NAMES),
          morto: randomFrom(NAMES),
          arma: randomFrom(WEAPONS),
        })
      }, 500 + i * 400)
    }
  }, [])

  return (
    <div className="dev-panel">
      <h3>DEV MODE</h3>
      <div className="dev-row">
        <button onClick={showMenu}>Show</button>
        <button onClick={hideMenu}>Hide</button>
        <button onClick={hideAll}>Hide All</button>
      </div>
      <div className="dev-row">
        <button onClick={startTimer}>Timer 30:00</button>
        <button onClick={updateTimer}>Update Timer</button>
      </div>
      <div className="dev-row">
        <button onClick={addKill}>+ Kill</button>
        <button onClick={addKillBurst}>+ 3 Kills</button>
      </div>
      <div className="dev-row">
        <button className="dev-demo" onClick={demoFull}>Demo Completa</button>
      </div>
    </div>
  )
}

export default DevPanel
