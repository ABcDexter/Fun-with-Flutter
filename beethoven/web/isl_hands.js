import {
  FilesetResolver,
  HandLandmarker,
} from 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14';

const state = {
  initialized: false,
  initPromise: null,
  handLandmarker: null,
};

function clamp01(value) {
  return Math.max(0, Math.min(1, value));
}

function computeBoxFromLandmarks(landmarks) {
  let minX = 1;
  let minY = 1;
  let maxX = 0;
  let maxY = 0;

  for (const point of landmarks) {
    minX = Math.min(minX, point.x);
    minY = Math.min(minY, point.y);
    maxX = Math.max(maxX, point.x);
    maxY = Math.max(maxY, point.y);
  }

  const width = Math.max(0.0001, maxX - minX);
  const height = Math.max(0.0001, maxY - minY);

  const marginX = width * 0.35;
  const marginY = height * 0.35;

  const expandedMinX = clamp01(minX - marginX);
  const expandedMinY = clamp01(minY - marginY);
  const expandedMaxX = clamp01(maxX + marginX);
  const expandedMaxY = clamp01(maxY + marginY);

  return {
    x: expandedMinX,
    y: expandedMinY,
    width: Math.max(0.0001, expandedMaxX - expandedMinX),
    height: Math.max(0.0001, expandedMaxY - expandedMinY),
  };
}

async function init() {
  if (state.initialized) {
    return true;
  }
  if (state.initPromise) {
    return state.initPromise;
  }

  state.initPromise = (async () => {
    const vision = await FilesetResolver.forVisionTasks(
      'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/wasm'
    );

    state.handLandmarker = await HandLandmarker.createFromOptions(vision, {
      baseOptions: {
        modelAssetPath:
          'https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task',
      },
      numHands: 1,
      runningMode: 'VIDEO',
      minHandDetectionConfidence: 0.5,
      minHandPresenceConfidence: 0.5,
      minTrackingConfidence: 0.5,
    });

    state.initialized = true;
    return true;
  })();

  return state.initPromise;
}

async function detect(videoElement) {
  if (!state.initialized) {
    await init();
  }

  if (!videoElement || videoElement.readyState < 2) {
    return null;
  }

  const result = state.handLandmarker.detectForVideo(videoElement, performance.now());
  if (!result || !result.landmarks || result.landmarks.length === 0) {
    return null;
  }

  const landmarks = result.landmarks[0];
  const box = computeBoxFromLandmarks(landmarks);

  return {
    x: box.x,
    y: box.y,
    width: box.width,
    height: box.height,
    score: 1.0,
  };
}

window.islHands = {
  init,
  detect,
};
