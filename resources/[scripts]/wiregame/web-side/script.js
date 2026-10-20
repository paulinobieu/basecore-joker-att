//--------------------------------------------------------------------------------------------------------------------------------------
// SETTINGS
//--------------------------------------------------------------------------------------------------------------------------------------
const Origins = [185,375,560,745]
const Connector = 790
const Distance = 670
const Radius = 65
const Motion = 300
const Outro = 1200
//--------------------------------------------------------------------------------------------------------------------------------------
// ELEMENTS
//--------------------------------------------------------------------------------------------------------------------------------------
const App = document.getElementById("app")
const Duration = document.querySelector(".Duration")
const Board = document.querySelector("#app svg")
const Lights = Array.from(document.querySelectorAll("[data-light]"))
const Sockets = Array.from(document.querySelectorAll(".SocketBack")).map(function(Element) {
	return { Back: Element,Face: document.querySelector(".SocketFace[data-socket=\""+Element.dataset.socket+"\"]") }
})
const Wires = Array.from(document.querySelectorAll(".Wire")).map(function(Element,Index) {
	return {
		Index: Index,
		Element: Element,
		Handle: Element.querySelector(".WireHandle"),
		Cables: Array.from(Element.querySelectorAll(".WireCable")),
		Token: 0
	}
})
//--------------------------------------------------------------------------------------------------------------------------------------
// SOUNDS
//--------------------------------------------------------------------------------------------------------------------------------------
const Sounds = {
	Open: new Audio("./sounds/open.mp3"),
	Close: new Audio("./sounds/close.mp3"),
	Success: new Audio("./sounds/success.mp3"),
	Connect: [
		new Audio("./sounds/connect1.mp3"),
		new Audio("./sounds/connect2.mp3"),
		new Audio("./sounds/connect3.mp3"),
		new Audio("./sounds/connect4.mp3")
	]
}
//--------------------------------------------------------------------------------------------------------------------------------------
// VARIABLES
//--------------------------------------------------------------------------------------------------------------------------------------
let Opened = false
let Running = false
let Deadline = 0
let Frame = null
let Order = []
let Dragging = null
//--------------------------------------------------------------------------------------------------------------------------------------
// PLAY
//--------------------------------------------------------------------------------------------------------------------------------------
function Play(Sound) {
	Sound.volume = 0.4
	Sound.currentTime = 0
	Sound.play().catch(function() {})
}
//--------------------------------------------------------------------------------------------------------------------------------------
// POST
//--------------------------------------------------------------------------------------------------------------------------------------
function Post(Action,Payload) {
	fetch("https://"+GetParentResourceName()+"/"+Action,{
		method: "POST",
		headers: { "Content-Type": "application/json; charset=UTF-8" },
		body: JSON.stringify(Payload || {})
	}).catch(function() {})
}
//--------------------------------------------------------------------------------------------------------------------------------------
// SHUFFLE
//--------------------------------------------------------------------------------------------------------------------------------------
function Shuffle(Length) {
	const Values = Array.from({ length: Length },function(Value,Index) { return Index })

	for (let Index = Values.length - 1; Index > 0; Index--) {
		const Target = Math.floor(Math.random() * (Index + 1))
		const Buffer = Values[Index]

		Values[Index] = Values[Target]
		Values[Target] = Buffer
	}

	return Values
}
//--------------------------------------------------------------------------------------------------------------------------------------
// FORMAT
//--------------------------------------------------------------------------------------------------------------------------------------
function Format(Amount) {
	const Total = Math.ceil(Amount)
	const Minutes = Math.floor(Total / 60)
	const Rest = Total % 60

	return Minutes+":"+String(Rest).padStart(2,"0")
}
//--------------------------------------------------------------------------------------------------------------------------------------
// CABLE
//--------------------------------------------------------------------------------------------------------------------------------------
function Cable(Wire,X,Y) {
	Wire.Handle.setAttribute("transform","translate("+X+","+Y+")")

	Wire.Cables.forEach(function(Element) {
		Element.setAttribute("x2",120 + X)
		Element.setAttribute("y2",Origins[Wire.Index] + Y)
	})
}
//--------------------------------------------------------------------------------------------------------------------------------------
// TWEEN
//--------------------------------------------------------------------------------------------------------------------------------------
function Tween(Wire,FromX,FromY,ToX,ToY,Callback) {
	const Token = ++Wire.Token
	const Start = performance.now()

	function Step(Now) {
		if (Wire.Token !== Token) {
			return
		}

		const Delta = Math.min((Now - Start) / Motion,1)
		const Ease = 1 - Math.pow(1 - Delta,3)

		Cable(Wire,FromX + (ToX - FromX) * Ease,FromY + (ToY - FromY) * Ease)

		if (Delta < 1) {
			requestAnimationFrame(Step)
		} else if (Callback) {
			Callback()
		}
	}

	requestAnimationFrame(Step)
}
//--------------------------------------------------------------------------------------------------------------------------------------
// POSITION
//--------------------------------------------------------------------------------------------------------------------------------------
function Position(Event) {
	const Point = Board.createSVGPoint()

	Point.x = Event.clientX
	Point.y = Event.clientY

	return Point.matrixTransform(Board.getScreenCTM().inverse())
}
//--------------------------------------------------------------------------------------------------------------------------------------
// NEAREST
//--------------------------------------------------------------------------------------------------------------------------------------
function Nearest(X,Y) {
	let Result = null
	let Closest = Radius

	Origins.forEach(function(Origin,Socket) {
		const Length = Math.hypot(Connector - X,Origin - Y)

		if (Length <= Closest) {
			Closest = Length
			Result = Socket
		}
	})

	return Result
}
//--------------------------------------------------------------------------------------------------------------------------------------
// CONNECT
//--------------------------------------------------------------------------------------------------------------------------------------
function Connect(Wire,Socket,X,Y) {
	Wire.Element.classList.add("Connected")
	Lights[Socket].classList.add("Active")

	Tween(Wire,X,Y,Distance,Origins[Socket] - Origins[Wire.Index])

	if (Wires.every(function(Value) { return Value.Element.classList.contains("Connected") })) {
		Running = false

		cancelAnimationFrame(Frame)
		Play(Sounds.Success)
		setTimeout(function() { Close(true) },Outro)
	} else {
		Play(Sounds.Connect[Socket])
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------
// DRAG
//--------------------------------------------------------------------------------------------------------------------------------------
Wires.forEach(function(Wire) {
	Wire.Handle.addEventListener("pointerdown",function(Event) {
		if (!Running || Dragging || Wire.Element.classList.contains("Connected")) {
			return
		}

		Event.preventDefault()

		const Point = Position(Event)

		Wire.Token++
		Dragging = { Wire: Wire,Pointer: Event.pointerId,X: Point.x,Y: Point.y,OffsetX: 0,OffsetY: 0 }
		Wire.Handle.setPointerCapture(Event.pointerId)
	})

	Wire.Handle.addEventListener("pointermove",function(Event) {
		if (!Dragging || Dragging.Wire !== Wire) {
			return
		}

		const Point = Position(Event)

		Dragging.OffsetX = Point.x - Dragging.X
		Dragging.OffsetY = Point.y - Dragging.Y

		Cable(Wire,Dragging.OffsetX,Dragging.OffsetY)
	})

	Wire.Handle.addEventListener("lostpointercapture",function() {
		if (!Dragging || Dragging.Wire !== Wire) {
			return
		}

		const OffsetX = Dragging.OffsetX
		const OffsetY = Dragging.OffsetY
		const Socket = Nearest(120 + OffsetX,Origins[Wire.Index] + OffsetY)

		Dragging = null

		if (Running && Socket !== null && Order[Socket] === Wire.Index) {
			Connect(Wire,Socket,OffsetX,OffsetY)
		} else {
			Tween(Wire,OffsetX,OffsetY,0,0)
		}
	})
})
//--------------------------------------------------------------------------------------------------------------------------------------
// TIMER
//--------------------------------------------------------------------------------------------------------------------------------------
function Timer() {
	const Remaining = Math.max(Deadline - performance.now(),0)

	Duration.textContent = Format(Remaining / 1000)

	if (Remaining <= 0) {
		return Failure()
	}

	Frame = requestAnimationFrame(Timer)
}
//--------------------------------------------------------------------------------------------------------------------------------------
// OPEN
//--------------------------------------------------------------------------------------------------------------------------------------
function Open(Payload) {
	if (Opened) {
		return
	}

	Order = Shuffle(Wires.length)

	Wires.forEach(function(Wire) {
		Wire.Token++
		Wire.Element.classList.remove("Connected")

		Cable(Wire,0,0)
	})

	Sockets.forEach(function(Socket,Index) {
		Socket.Back.dataset.wire = Order[Index]
		Socket.Face.dataset.wire = Order[Index]
	})

	Lights.forEach(function(Light) {
		Light.classList.remove("Active")
	})

	Opened = true
	Running = true
	Dragging = null
	Deadline = performance.now() + Math.max(parseInt(Payload[0]) || 30,1) * 1000

	App.classList.add("Active")

	Play(Sounds.Open)

	Frame = requestAnimationFrame(Timer)
}
//--------------------------------------------------------------------------------------------------------------------------------------
// CLOSE
//--------------------------------------------------------------------------------------------------------------------------------------
function Close(Success) {
	if (!Opened) {
		return
	}

	Opened = false
	Running = false
	Dragging = null

	cancelAnimationFrame(Frame)
	App.classList.remove("Active")
	Post(Success ? "Success" : "Failure")
}
//--------------------------------------------------------------------------------------------------------------------------------------
// FAILURE
//--------------------------------------------------------------------------------------------------------------------------------------
function Failure() {
	if (!Running) {
		return
	}

	Play(Sounds.Close)
	Close(false)
}
//--------------------------------------------------------------------------------------------------------------------------------------
// KEYBOARD
//--------------------------------------------------------------------------------------------------------------------------------------
document.addEventListener("keydown",function(Event) {
	if (Event.key === "Escape") {
		Failure()
	}
})
//--------------------------------------------------------------------------------------------------------------------------------------
// MESSAGES
//--------------------------------------------------------------------------------------------------------------------------------------
window.addEventListener("message",function(Event) {
	const Data = Event.data

	if (Data.Action === "Open") {
		Open(Data.Payload)
	}
})
