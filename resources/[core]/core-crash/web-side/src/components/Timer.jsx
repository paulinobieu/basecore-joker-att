import './Timer.css'

const TimerIcon = () => (
  <svg width="34" height="34" viewBox="0 0 34 34" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path
      d="M17 8.5C12.3056 8.5 8.5 12.3056 8.5 17C8.5 21.6944 12.3056 25.5 17 25.5C21.6944 25.5 25.5 21.6944 25.5 17C25.5 12.3056 21.6944 8.5 17 8.5ZM17 23.375C13.4781 23.375 10.625 20.5219 10.625 17C10.625 13.4781 13.4781 10.625 17 10.625C20.5219 10.625 23.375 13.4781 23.375 17C23.375 20.5219 20.5219 23.375 17 23.375Z"
      fill="white"
    />
    <path d="M17.7083 12.75H16.2917V18.0625H21.25V16.6458H17.7083V12.75Z" fill="white" />
  </svg>
)

function Timer({ time }) {
  return (
    <div className="timer-wrapper">
      <div className="timer-accent-top" />
      <div className="timer-bg">
        <div className="timer-icon">
          <TimerIcon />
        </div>
        <span className="timer-text">{time}</span>
      </div>
      <div className="timer-accent-bottom" />
    </div>
  )
}

export default Timer
