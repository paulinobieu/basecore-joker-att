import type { Job } from '../App'
import { ArrowRightFaded } from './Icons'

interface JobCardProps {
    job: Job
    imageUrl: string
    onStart: () => void
}

export default function JobCard({ job, imageUrl, onStart }: JobCardProps) {
    return (
        <article className="job-card">
            {/* Image */}
            <div className="job-card-image">
                <img src={imageUrl} alt={job.name} />
                <div className="job-card-image-overlay" />
                {/* XP badge */}
                <div className="job-level-badge">
                    <span>LVL {job.jobLevel}</span>
                </div>
            </div>

            {/* Body */}
            <div className="job-card-body">
                {/* Name & salary row */}
                <div className="job-card-name-row">
                    <span className="job-card-name">{job.name}</span>
                    <span className="job-card-salary">R$ {job.salary}</span>
                </div>

                {/* Description */}
                <p className="job-card-desc">{job.description}</p>

                {/* Start button */}
                <button type="button" className="job-card-start-btn" onClick={onStart}>
                    <span className="job-card-start-text">Começar trabalho</span>
                    <span className="job-card-start-icon">
                        <ArrowRightFaded />
                    </span>
                </button>
            </div>
        </article>
    )
}
