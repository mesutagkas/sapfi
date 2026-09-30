import { hashPassword, needsRehash, verifyPassword } from "@depar/shared";

describe("şifre özetleme", () => {
  it("doğru şifreyi doğrular, yanlışı reddeder", async () => {
    const hash = await hashPassword("Depar1234!");
    await expect(verifyPassword("Depar1234!", hash)).resolves.toBe(true);
    await expect(verifyPassword("Depar1234", hash)).resolves.toBe(false);
  });

  it("aynı şifre için farklı tuz üretir", async () => {
    const a = await hashPassword("Depar1234!");
    const b = await hashPassword("Depar1234!");
    expect(a).not.toEqual(b);
  });

  it("güncel parametrelerde yeniden özetleme istemez", async () => {
    expect(needsRehash(await hashPassword("Depar1234!"))).toBe(false);
    expect(needsRehash("bcrypt$10$abc")).toBe(true);
  });

  it("bozuk özet biçimini reddeder", async () => {
    await expect(verifyPassword("x", "saçma-veri")).resolves.toBe(false);
  });
});
