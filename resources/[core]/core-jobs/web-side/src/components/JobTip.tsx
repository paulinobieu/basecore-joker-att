import React, { useState } from 'react'
import { useNuiEvent } from '../hooks/useNuiEvent'
import './JobTip.css'

type JobTipPosition =
    | 'bottom-left'
    | 'bottom-center'
    | 'bottom-right'
    | 'top-left'
    | 'top-center'
    | 'top-right'
    | 'middle-left'
    | 'middle-right'

interface JobTipData {
    text: string
    position?: JobTipPosition
}

const VALID_POSITIONS: ReadonlySet<JobTipPosition> = new Set<JobTipPosition>([
    'bottom-left',
    'bottom-center',
    'bottom-right',
    'top-left',
    'top-center',
    'top-right',
    'middle-left',
    'middle-right',
])

const JobTip: React.FC = () => {
    const [tip, setTip] = useState<string | null>(null)
    const [position, setPosition] = useState<JobTipPosition>('bottom-left')

    useNuiEvent<JobTipData>('setJobTip', (data) => {
        if (data && data.text) {
            setTip(data.text)
            if (data.position && VALID_POSITIONS.has(data.position)) {
                setPosition(data.position)
            }
        } else {
            setTip(null)
        }
    })

    if (!tip) return null

    return (
        <div className="job-tip-container" data-position={position}>
            <div className="job-tip-badge">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2C9.24 2 7 4.24 7 7C7 9.76 9.24 12 12 12C14.76 12 17 9.76 17 7C17 4.24 14.76 2 12 2ZM12 14C8.67 14 2 15.67 2 19V22H22V19C22 15.67 15.33 14 12 14Z" fill="currentColor" />
                </svg>
                <span>EMPREGO</span>
            </div>
            <div className="job-tip-content">
                <div className="job-tip-text" dangerouslySetInnerHTML={{ __html: tip }} />
                <div className="job-tip-footer">
                    PRESSIONE <strong>F7</strong> PARA SAIR DO EMPREGO
                </div>
            </div>
        </div>
    )
}

export default JobTip
