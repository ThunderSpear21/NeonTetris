import { publish } from '../redis/publisher.js';

const activeGameLoops = new Map();

const SPEED_UP_INTERVALS = [
  { time: 0, tickRate: 10000 },  
  { time: 30000, tickRate: 9000 },  
  { time: 60000, tickRate: 7000 }, 
  { time: 120000, tickRate: 6000 }, 
  { time: 180000, tickRate: 5000 }, 
  { time: 240000, tickRate: 4000 }, 
];


function getCurrentTickRate(elapsedTime) {
  let currentRate = SPEED_UP_INTERVALS[0].tickRate;
  for (const interval of SPEED_UP_INTERVALS) {
    if (elapsedTime >= interval.time) {
      currentRate = interval.tickRate;
    }
  }
  return currentRate;
}

function startGameLoop(roomCode, startedAt) {
  if (activeGameLoops.has(roomCode)) {
    console.warn(`Game loop for room ${roomCode} already exists.`);
    return;
  }

  const loop = {
    lastTickRate: SPEED_UP_INTERVALS[0].tickRate,
  };

  const intervalId = setInterval(() => {
    const elapsedTime = Date.now() - new Date(startedAt).getTime();
    const newTickRate = getCurrentTickRate(elapsedTime);

    if (newTickRate !== loop.lastTickRate) {
      loop.lastTickRate = newTickRate;

      publish("gameUpdates", {
        roomCode,
        message: {
          type: "tickUpdate",
          payload: { newTickRate },
        },
      });
    }
  }, 1000);

  loop.intervalId = intervalId;
  activeGameLoops.set(roomCode, loop);
  console.log(`✅ Game loop started for room: ${roomCode}`);
}

function stopGameLoop(roomCode) {
  if (activeGameLoops.has(roomCode)) {
    const { intervalId } = activeGameLoops.get(roomCode);
    clearInterval(intervalId);
    activeGameLoops.delete(roomCode);
    console.log(`🛑 Game loop stopped for room: ${roomCode}`);
  }
}

export { startGameLoop, stopGameLoop };
