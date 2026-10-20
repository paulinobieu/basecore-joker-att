import { CoreLogoIcon, HomeIcon, HomeIconFaded, MissoesIcon, MissoesIconActive, BonusIcon, BonusIconActive, RankingIcon, RankingIconActive, SairIcon } from './Icons'
import CraftSidebarFrame from './CraftSidebarFrame'

interface SidebarProps {
    activeTab: 'home' | 'missions' | 'bonus' | 'ranking'
    onTabChange: (tab: 'home' | 'missions' | 'bonus' | 'ranking') => void
    onExit: () => void
}

export default function Sidebar({ activeTab, onTabChange, onExit }: SidebarProps) {
    return (
        <aside className="sidebar">
            <div className="sidebar-logo" aria-label="Central de empregos">
                <CoreLogoIcon />
            </div>

            <nav className="sidebar-nav" aria-label="Navegação da central de empregos">
                <button
                    type="button"
                    title="Empregos"
                    aria-label="Empregos"
                    className={`sidebar-tab ${activeTab === 'home' ? 'active' : ''}`}
                    onClick={() => onTabChange('home')}
                >
                    <CraftSidebarFrame id="jobs-home" />
                    {activeTab === 'home' ? <HomeIcon /> : <HomeIconFaded />}
                </button>

                <button
                    type="button"
                    title="Missões"
                    aria-label="Missões"
                    className={`sidebar-tab ${activeTab === 'missions' ? 'active' : ''}`}
                    onClick={() => onTabChange('missions')}
                >
                    <CraftSidebarFrame id="jobs-missions" />
                    {activeTab === 'missions' ? <MissoesIconActive /> : <MissoesIcon />}
                </button>

                <button
                    type="button"
                    title="Bônus"
                    aria-label="Bônus"
                    className={`sidebar-tab ${activeTab === 'bonus' ? 'active' : ''}`}
                    onClick={() => onTabChange('bonus')}
                >
                    <CraftSidebarFrame id="jobs-bonus" />
                    {activeTab === 'bonus' ? <BonusIconActive /> : <BonusIcon />}
                </button>

                <button
                    type="button"
                    title="Ranking"
                    aria-label="Ranking"
                    className={`sidebar-tab ${activeTab === 'ranking' ? 'active' : ''}`}
                    onClick={() => onTabChange('ranking')}
                >
                    <CraftSidebarFrame id="jobs-ranking" />
                    {activeTab === 'ranking' ? <RankingIconActive /> : <RankingIcon />}
                </button>
            </nav>

            <button type="button" className="sidebar-exit" title="Fechar" aria-label="Fechar" onClick={onExit}>
                <CraftSidebarFrame id="jobs-exit" />
                <SairIcon />
            </button>
        </aside>
    )
}
