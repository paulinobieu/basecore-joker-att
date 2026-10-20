interface SpatialSource {
	audioEl: HTMLAudioElement;
	srcNode: MediaElementAudioSourceNode;
	gain: GainNode;
	panner: PannerNode;
	file: string;
	playing: boolean;
}

interface ListenerData {
	x: number;
	y: number;
	z: number;
	heading: number;
}

interface SourceData {
	id: string | number;
	x: number;
	y: number;
	z: number;
	gain: number;
}

let audioCtx: AudioContext | null = null;
let masterGain: GainNode | null = null;
let muted = false;

const SOURCES = new Map<string, SpatialSource>();

function ensureAudioCtx() {
	try {
		if (!audioCtx) {
			audioCtx = new (window.AudioContext ||
				(window as any).webkitAudioContext)();
			masterGain = audioCtx.createGain();
			masterGain.gain.value = muted ? 0.0 : 1.0;
			masterGain.connect(audioCtx.destination);

			try {
				audioCtx.listener.forwardX.value = 0;
				audioCtx.listener.forwardY.value = 1;
				audioCtx.listener.forwardZ.value = 0;
				audioCtx.listener.upX.value = 0;
				audioCtx.listener.upY.value = 0;
				audioCtx.listener.upZ.value = 1;
			} catch {}
		}

		if (audioCtx && audioCtx.state === "suspended") {
			audioCtx.resume().catch(() => {});
		}
	} catch {}
}

export function setAudioMuted(value: boolean) {
	muted = !!value;
	if (masterGain) {
		masterGain.gain.value = muted ? 0.0 : 1.0;
	}
}

function getOrCreateSource(
	id: string | number,
	file: string,
): SpatialSource | null {
	ensureAudioCtx();
	if (!audioCtx || !masterGain) return null;

	const key = String(id);
	const existing = SOURCES.get(key);
	if (existing && existing.file === file) return existing;

	if (existing) {
		stopSound3D(key);
	}

	const audioEl = new Audio();
	audioEl.preload = "auto";
	audioEl.loop = true;
	audioEl.src = `../../sounds/${file}`;
	audioEl.crossOrigin = "anonymous";

	let srcNode: MediaElementAudioSourceNode;
	try {
		srcNode = audioCtx.createMediaElementSource(audioEl);
	} catch {
		return null;
	}

	const gain = audioCtx.createGain();
	gain.gain.value = 0.0;

	const panner = audioCtx.createPanner();
	panner.panningModel = "HRTF";
	panner.distanceModel = "inverse";
	panner.refDistance = 2.0;
	panner.maxDistance = 35.0;
	panner.rolloffFactor = 1.5;
	panner.coneInnerAngle = 360;
	panner.coneOuterAngle = 0;
	panner.coneOuterGain = 0;

	srcNode.connect(gain);
	gain.connect(panner);
	panner.connect(masterGain);

	const obj: SpatialSource = {
		audioEl,
		srcNode,
		gain,
		panner,
		file,
		playing: false,
	};
	SOURCES.set(key, obj);
	return obj;
}

export function playSound3D(
	id: string | number,
	file: string,
	baseVol = 0.4,
) {
	const s = getOrCreateSource(id, file);
	if (!s) return;

	try {
		s.audioEl.volume = Math.max(0.0, Math.min(1.0, Number(baseVol) || 0.4));
	} catch {}

	if (!s.playing) {
		const p = s.audioEl.play();
		if (p && p.catch) p.catch(() => {});
		s.playing = true;
	}
}

export function stopSound3D(id: string | number) {
	const key = String(id);
	const s = SOURCES.get(key);
	if (!s) return;

	try {
		s.audioEl.pause();
		s.audioEl.currentTime = 0;
		s.audioEl.src = "";
	} catch {}

	try {
		s.srcNode.disconnect();
	} catch {}
	try {
		s.gain.disconnect();
	} catch {}
	try {
		s.panner.disconnect();
	} catch {}

	SOURCES.delete(key);
}

export function stopAllSounds() {
	for (const [id] of SOURCES) {
		stopSound3D(id);
	}
}

function degToRad(deg: number) {
	return deg * (Math.PI / 180);
}

export function updateAudio(
	listener?: ListenerData,
	sources?: SourceData[],
) {
	ensureAudioCtx();
	if (!audioCtx) return;

	if (listener) {
		const lx = Number(listener.x) || 0;
		const ly = Number(listener.y) || 0;
		const lz = Number(listener.z) || 0;
		const heading = Number(listener.heading) || 0;

		try {
			audioCtx.listener.positionX.value = lx;
			audioCtx.listener.positionY.value = ly;
			audioCtx.listener.positionZ.value = lz;
		} catch {
			try {
				(audioCtx.listener as any).setPosition(lx, ly, lz);
			} catch {}
		}

		const rad = degToRad(heading);
		const fx = Math.sin(rad);
		const fy = Math.cos(rad);
		const fz = 0;

		try {
			audioCtx.listener.forwardX.value = fx;
			audioCtx.listener.forwardY.value = fy;
			audioCtx.listener.forwardZ.value = fz;

			audioCtx.listener.upX.value = 0;
			audioCtx.listener.upY.value = 0;
			audioCtx.listener.upZ.value = 1;
		} catch {
			try {
				(audioCtx.listener as any).setOrientation(fx, fy, fz, 0, 0, 1);
			} catch {}
		}
	}

	if (!Array.isArray(sources)) return;

	for (const it of sources) {
		const id = String(it.id ?? "");
		if (!id) continue;

		const s = SOURCES.get(id);
		if (!s) continue;

		const x = Number(it.x) || 0;
		const y = Number(it.y) || 0;
		const z = Number(it.z) || 0;
		const g = Math.max(0.0, Math.min(1.0, Number(it.gain) || 0.0));

		try {
			s.panner.positionX.value = x;
			s.panner.positionY.value = y;
			s.panner.positionZ.value = z;
		} catch {
			try {
				(s.panner as any).setPosition(x, y, z);
			} catch {}
		}

		try {
			s.gain.gain.value = g;

			if (g <= 0.001) {
				if (s.playing) {
					s.audioEl.pause();
					s.playing = false;
				}
			} else {
				if (!s.playing) {
					const p = s.audioEl.play();
					if (p && p.catch) p.catch(() => {});
					s.playing = true;
				}
			}
		} catch {}
	}
}
