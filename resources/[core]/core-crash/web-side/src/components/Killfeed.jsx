import { useState, useEffect } from 'react'
import './Killfeed.css'

const WEAPONS_BASE = './weapons/'
const FALLBACK_IMAGE = WEAPONS_BASE + 'weapon_bullpuprifle_mk2.png'

const WEAPON_IMAGE_MAP = {
  WEAPON_HK416: 'weapon_carbinerifle.png',
  WEAPON_HKBOPE: 'weapon_carbinerifle.png',
  WEAPON_BCM4: 'weapon_carbinerifle.png',
  WEAPON_M4BAL: 'weapon_carbinerifle_mk2.png',
  WEAPON_M4GOLD: 'weapon_carbinerifle_mk2.png',
  WEAPON_M16A4CAMMO: 'weapon_carbinerifle.png',
  WEAPON_M16A4TCP: 'weapon_carbinerifle.png',
  WEAPON_BARRETMENGO: 'weapon_heavysniper.png',
  WEAPON_HK417DENDE: 'weapon_marksmanrifle.png',
  WEAPON_SIG_MCX: 'weapon_carbinerifle.png',
  WEAPON_GLOCKNORM: 'weapon_combatpistol.png',
  WEAPON_GLOCKRAJADA: 'weapon_combatpistol.png',
  WEAPON_GLOCKRELIKIASHOPFEMININO: 'weapon_pistol_mk2.png',
  WEAPON_G3RELIKIASHOPFEMININO: 'weapon_specialcarbine_mk2.png',
  WEAPON_ARRELIKIASHOPFEMININO1: 'weapon_assaultrifle.png',
  WEAPON_aktamb: 'weapon_assaultrifle.png',
  WEAPON_G3ANIMEFLAY: 'weapon_specialcarbine_mk2.png',
  WEAPON_G36KUROMIFLAY: 'weapon_specialcarbine_mk2.png',
  WEAPON_G36BBATTLEHOSTFLAY: 'weapon_specialcarbine_mk2.png',
  WEAPON_PI_FIVEFASTCUPFEMFLAY: 'weapon_pistol_mk2.png',
  WEAPON_PI_FASTCUPFLAYMASC: 'weapon_pistol_mk2.png',
  WEAPON_G3SIGXTRANHOFLAY: 'weapon_specialcarbine.png',
  WEAPON_G3REDFLOWERFLAY: 'weapon_specialcarbine_mk2.png',
  WEAPON_ASSAULTRIFLE1_STORM: 'weapon_assaultrifle.png',
  WEAPON_EO_PACKRGX_ASSAULTRIFLE: 'weapon_assaultrifle.png',
  EO_CARBINE_01: 'weapon_carbinerifle.png',
  WEAPON_ONI: 'weapon_carbinerifle_mk2.png',
  WEAPON_M4ANIME: 'weapon_carbinerifle_mk2.png',
  WEAPON_EO_CARBINERIFLEMK2_HALLOWEEN: 'weapon_carbinerifle_mk2.png',
  WEAPON_SPECIALCARBINE1_STORM: 'weapon_specialcarbine.png',
  WEAPON_EO_PACKRGX_SPECIALCARBINE: 'weapon_specialcarbine.png',
  WEAPON_EO_HALLOWEEN_SPECIALCARBINEMK2: 'weapon_specialcarbine.png',
  WEAPON_PL_PENHASHOP_G3_HALLOWEEN: 'weapon_specialcarbine_mk2.png',
  EO_G36_01: 'weapon_specialcarbine_mk2.png',
  EO_G36_02: 'weapon_specialcarbine_mk2.png',
  WEAPON_G3HELLFIRE: 'weapon_specialcarbine_mk2.png',
  WEAPON_PL_G3_LEVELUP_G: 'weapon_specialcarbine_mk2.png',
  WEAPON_PL_PISTOL_LEVELUP_G: 'weapon_pistol_mk2.png',
  WEAPON_EO_PACKRGX_MACHINEPISTOL: 'weapon_machinepistol.png',
  WEAPON_RAIJIN: 'weapon_appistol.png',
  WEAPON_APPISTOL1_STORM: 'weapon_appistol.png',
  WEAPON_EO_PACKRGX_APPISTOL: 'weapon_appistol.png',
  WEAPON_PL_PENHASHOP_PISTOL_HALLOWEEN_AUTO: 'weapon_appistol.png',
  WEAPON_KNIFEWHITEFIRE: 'weapon_knife.png',
  WEAPON_PL_FACA_LEVELUP_G: 'weapon_knife.png',
  WEAPON_EO_PACKRGX_KNIFE: 'weapon_knife.png',
  WEAPON_BAT1: 'weapon_bat.png',
  WEAPON_MICROSMG1: 'weapon_microsmg.png',
  WEAPON_PL_MTAR_LEVELUP_G: 'weapon_combatpdw.png',
}

const SkullIcon = () => (
  <svg width="16" height="20" viewBox="0 0 16 20" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path
      d="M8 0C3.6 0 0 3.6 0 8C0 11.2 1.8 13.9 4.4 15.3V18C4.4 19.1 5.3 20 6.4 20H9.6C10.7 20 11.6 19.1 11.6 18V15.3C14.2 13.9 16 11.2 16 8C16 3.6 12.4 0 8 0ZM5.2 10.8C4.1 10.8 3.2 9.9 3.2 8.8C3.2 7.7 4.1 6.8 5.2 6.8C6.3 6.8 7.2 7.7 7.2 8.8C7.2 9.9 6.3 10.8 5.2 10.8ZM10.8 10.8C9.7 10.8 8.8 9.9 8.8 8.8C8.8 7.7 9.7 6.8 10.8 6.8C11.9 6.8 12.8 7.7 12.8 8.8C12.8 9.9 11.9 10.8 10.8 10.8Z"
      fill="white"
    />
  </svg>
)

function getWeaponImageUrl(weapon) {
  if (!weapon) return FALLBACK_IMAGE
  const mapped = WEAPON_IMAGE_MAP[weapon]
  if (mapped) return WEAPONS_BASE + mapped
  const filename = weapon.toLowerCase() + '.png'
  return WEAPONS_BASE + filename
}

function KillItem({ kill }) {
  const [exiting, setExiting] = useState(false)
  const [imgSrc, setImgSrc] = useState(() => getWeaponImageUrl(kill.arma))

  useEffect(() => {
    const exitTimer = setTimeout(() => setExiting(true), 6200)
    return () => clearTimeout(exitTimer)
  }, [])

  const handleImageError = () => setImgSrc(FALLBACK_IMAGE)

  return (
    <div className={`kill-item ${exiting ? 'kill-exit' : 'kill-enter'}`}>
      <div className="kill-bg">
        <span className="kill-name kill-killer">{kill.matador}</span>
        <div className="kill-weapon-area">
          <img
            src={imgSrc}
            alt=""
            className="kill-weapon-img"
            onError={handleImageError}
          />
        </div>
        <span className="kill-name kill-dead">{kill.morto}</span>
        <div className="kill-icon-box">
          <SkullIcon />
        </div>
      </div>
    </div>
  )
}

function Killfeed({ kills }) {
  return (
    <div className="killfeed-container">
      {kills.map((kill) => (
        <KillItem key={kill.id} kill={kill} />
      ))}
    </div>
  )
}

export default Killfeed
