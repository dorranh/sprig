package dev.appalachian.sprig.server

import io.grpc.netty.shaded.io.grpc.netty.NettyServerBuilder

import cats.effect.kernel.Resource
import cats.effect.IO
import io.grpc.ServerServiceDefinition
import fs2.grpc.syntax.all.*
import scala.concurrent.Future
import io.grpc.Metadata
import cats.effect.IOApp
import cats.effect.ExitCode

import com.example.protos.sprig.{
  GreeterFs2Grpc,
  HelloRequest,
  HelloReply,
  GetDataRequest,
  GetDataResponse
}

class ServerImplementation extends GreeterFs2Grpc[IO, Metadata] {
  def sayHello(request: HelloRequest, ctx: Metadata): IO[HelloReply] =
    IO.pure(HelloReply(message = "hello there :)"))

  def getData(request: GetDataRequest, ctx: Metadata): IO[GetDataResponse] =
    IO.pure(
      GetDataResponse(foo =
        f"Howdy! You requested data for use in the following call site: ${request.callerInfo}"
      )
    )
}

val grpcService: Resource[IO, ServerServiceDefinition] =
  GreeterFs2Grpc.bindServiceResource[IO](new ServerImplementation())

def runService(service: ServerServiceDefinition) = NettyServerBuilder
  .forPort(9999)
  .addService(service)
  .resource[IO]
  .evalMap(server => IO(server.start()))
  .useForever
  .map(_ => ExitCode.Success)

object Main extends IOApp {

  def run(args: List[String]): IO[ExitCode] =
    grpcService.use(runService)
}
