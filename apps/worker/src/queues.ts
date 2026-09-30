/**
 * Kuyruk tanımları — docs/01-MIMARI-VE-SUNUCU.md §2 ile birebir.
 * Faz 1'de yalnız altyapı ayakta; işlerin gövdesi Faz 2–3'te doldurulur.
 */
export const QUEUES = {
  productPush: "product.push",
  stockSync: "stock.sync",
  orderPull: "order.pull",
  orderDispatch: "order.dispatch",
  shipmentPush: "shipment.push",
  batchCheck: "batch.check",
  invoiceIssue: "invoice.issue",
  notifySend: "notify.send",
} as const;

export type QueueName = (typeof QUEUES)[keyof typeof QUEUES];

/** Tüm işlerin ortak varsayılanı: üstel geri çekilme, 5 deneme, iz bırakan kayıt. */
export const defaultJobOptions = {
  attempts: 5,
  backoff: { type: "exponential" as const, delay: 5_000 },
  removeOnComplete: { age: 86_400, count: 1_000 },
  removeOnFail: { age: 7 * 86_400 },
};
