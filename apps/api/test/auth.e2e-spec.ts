/**
 * Uçtan uca kayıt → giriş → /me → yenileme → çıkış akışı.
 * Çalıştırmak için ayakta bir PostgreSQL gerekir:  npm run infra:up && npm run test:e2e -w @depar/api
 */
import { INestApplication, ValidationPipe } from "@nestjs/common";
import { Test } from "@nestjs/testing";
import request from "supertest";
import { AppModule } from "../src/app.module";
import { PrismaService } from "../src/prisma/prisma.service";

describe("Auth (e2e)", () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const email = `test-${Date.now()}@depar.test`;
  const password = "Depar1234!";
  let refreshToken = "";

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
    await app.init();
    prisma = app.get(PrismaService);
  });

  afterAll(async () => {
    const user = await prisma.user.findUnique({ where: { email } });
    if (user?.tenantId) await prisma.tenant.delete({ where: { id: user.tenantId } });
    await app.close();
  });

  it("zayıf şifreyi reddeder", async () => {
    await request(app.getHttpServer())
      .post("/v1/auth/register")
      .send({ role: "seller", fullName: "Test Kullanıcı", companyName: "Test Ltd", email, password: "123" })
      .expect(400);
  });

  it("satıcı kaydı açar ve 14 günlük deneme başlatır", async () => {
    const res = await request(app.getHttpServer())
      .post("/v1/auth/register")
      .send({ role: "seller", fullName: "Test Kullanıcı", companyName: "Test Ltd", email, password })
      .expect(201);

    expect(res.body.tokens.accessToken).toBeDefined();
    expect(res.body.user.subscription.status).toBe("trialing");
    expect(res.body.user.subscription.planCode).toBe("pro");
    refreshToken = res.body.tokens.refreshToken;
  });

  it("aynı e-posta ile ikinci kayda izin vermez", async () => {
    await request(app.getHttpServer())
      .post("/v1/auth/register")
      .send({ role: "seller", fullName: "Test Kullanıcı", companyName: "Test Ltd", email, password })
      .expect(409);
  });

  it("yanlış şifreyle giriş yapılamaz", async () => {
    await request(app.getHttpServer())
      .post("/v1/auth/login")
      .send({ email, password: "YanlisSifre1" })
      .expect(401);
  });

  it("token'sız /me çağrısı reddedilir", async () => {
    await request(app.getHttpServer()).get("/v1/auth/me").expect(401);
  });

  it("giriş yapıp /me okur", async () => {
    const login = await request(app.getHttpServer()).post("/v1/auth/login").send({ email, password }).expect(200);
    const me = await request(app.getHttpServer())
      .get("/v1/auth/me")
      .set("Authorization", `Bearer ${login.body.tokens.accessToken}`)
      .expect(200);
    expect(me.body.email).toBe(email);
    expect(me.body.tenant.kind).toBe("seller");
  });

  it("refresh token'ı döndürür ve eskisini iptal eder", async () => {
    const first = await request(app.getHttpServer()).post("/v1/auth/refresh").send({ refreshToken }).expect(200);
    expect(first.body.accessToken).toBeDefined();
    await request(app.getHttpServer()).post("/v1/auth/refresh").send({ refreshToken }).expect(401);
  });
});
