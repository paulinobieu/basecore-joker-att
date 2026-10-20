import { useClickSound } from '@app/hooks/useClickSound'
import { Home } from '@views/pages/Home'

export default function App() {
  useClickSound()

  return <Home />
}
