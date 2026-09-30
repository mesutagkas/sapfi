import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus, Logger } from "@nestjs/common";
import type { Request, Response } from "express";
import { randomUUID } from "node:crypto";

/** Tüm hataları tek biçimde döndürür; beklenmeyen hatanın detayı istemciye sızmaz. */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger("Http");

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<Request>();
    const requestId = (req.headers["x-request-id"] as string) ?? randomUUID();

    const status = exception instanceof HttpException ? exception.getStatus() : HttpStatus.INTERNAL_SERVER_ERROR;

    let message: string | string[] = "Beklenmeyen bir hata oluştu.";
    let error = "internal_error";

    if (exception instanceof HttpException) {
      const body = exception.getResponse() as string | { message?: string | string[]; error?: string };
      if (typeof body === "string") {
        message = body;
      } else {
        message = body.message ?? exception.message;
        error = body.error ?? exception.name;
      }
    } else {
      this.logger.error(`[${requestId}] ${req.method} ${req.url}`, exception instanceof Error ? exception.stack : "");
    }

    res.status(status).json({
      statusCode: status,
      error,
      message,
      path: req.url,
      requestId,
      timestamp: new Date().toISOString(),
    });
  }
}
