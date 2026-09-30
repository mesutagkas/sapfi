import { Queue, Worker, type Processor } from "bullmq";
import IORedis from "ioredis";
import { QUEUES, defaultJobOptions, type QueueName } from "./queues";

const connection = new IORedis(process.env.REDIS_URL ?? "redis://localhost:6379", {
  maxRetriesPerRequest: null,
});

/** Faz 1: iş gövdeleri boş — kuyruk altyapısının ayakta olduğunu doğrular. */
const placeholder: Processor = async (job) => {
  console.log(`[${job.queueName}] iş alındı #${job.id}`, job.data);
  return { ok: true, note: "Faz 3'te gerçek işlemci bağlanacak" };
};

const names = Object.values(QUEUES) as QueueName[];

export const queues = Object.fromEntries(
  names.map((name) => [name, new Queue(name, { connection, defaultJobOptions })]),
) as Record<QueueName, Queue>;

const workers = names.map(
  (name) => new Worker(name, placeholder, { connection, concurrency: 5 }),
);

for (const w of workers) {
  w.on("failed", (job, err) => console.error(`[${w.name}] başarısız #${job?.id}: ${err.message}`));
}

console.log(`Depar worker hazır — ${names.length} kuyruk dinleniyor: ${names.join(", ")}`);

async function shutdown(): Promise<void> {
  console.log("Worker kapanıyor…");
  await Promise.all(workers.map((w) => w.close()));
  await connection.quit();
  process.exit(0);
}
process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
