val scala3Version = "3.2.1"

lazy val root = project
  .in(file("."))
  .settings(
    name         := "sprig",
    version      := "0.1.0-SNAPSHOT",
    scalaVersion := scala3Version,
    // NativeImage
    Compile / mainClass       := Some("dev.appalachian.sprig.server.Main"),
    nativeImageOutput         := file("artifacts") / "sprig-server",
    nativeImageAgentOutputDir := file("config"),
    nativeImageInstalled      := true,
    nativeImageCommand        := Seq("native-image"),
    nativeImageOptions ++= Seq(
      "-H:+ReportExceptionStackTraces",
      "--no-fallback",
      // #####################################################################
      // Classes to init at BUILD time
      // #####################################################################
      // For logging with slf4j, need to adjust native-image configuration
      // https://github.com/zio/zio-s3/issues/190
      "--initialize-at-build-time=org.slf4j",
      "--initialize-at-build-time=io.grpc.netty.shaded.io.netty.util.internal.logging", // TODO: Do I need this?
      // "--initialize-at-build-time=ch.qos.logback" // TODO: If logback is enabled then this will likely be needed.
      // #####################################################################
      // # Classes to init at RUN time
      // #####################################################################
      // In order to use netty, need a bunch of different native-image configurations.
      // See the following issue for some related info:
      // https://github.com/netty/netty/issues/10616
      "--initialize-at-build-time=io.grpc.netty.shaded.io.netty.util.AsciiString",
      "--initialize-at-build-time=io.grpc.netty.shaded.io.netty.util.internal.logging.Slf4JLoggerFactory",
      "--initialize-at-build-time=io.grpc.netty.shaded.io.netty.util.internal.StringUtil",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.DefaultFileRegion",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.epoll.Epoll",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.epoll.EpollEventArray",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.epoll.EpollEventLoop",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.epoll.Native",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.kqueue.KQueue",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.kqueue.KQueueEventArray",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.kqueue.KQueueEventLoop",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.kqueue.Native",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.unix.Errors",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.unix.IovArray",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.channel.unix.Limits",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.handler.codec.http.HttpResponseStatus",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.util.AbstractReferenceCounted",
      "--initialize-at-run-time=io.grpc.netty.shaded.io.netty.util.internal.logging.Log4JLogger",
      // #####################################################################
      // # Classes to trace for more detailed errors when native-image fails
      // #####################################################################
      "--trace-class-initialization=io.grpc.netty.shaded.io.netty.util.AbstractReferenceCounted",
      "--trace-class-initialization=io.grpc.netty.shaded.io.netty.util.internal.logging.Slf4JLoggerFactory",
      "--trace-class-initialization=io.grpc.netty.shaded.io.netty.util.internal.StringUtil",
      "--trace-class-initialization=io.grpc.netty.shaded.io.netty.util.internal.SystemPropertyUtil",
      "--trace-object-instantiation=io.grpc.netty.shaded.io.netty.util.AsciiString"
    ),
    // Dependencies
    libraryDependencies ++= Seq(
      // Core
      "org.typelevel" %% "cats-core"   % "2.9.0",
      "org.typelevel" %% "cats-effect" % "3.4.8", // "3.3.12", // % "3.4.8"
      // GRPC
      "io.grpc" % "grpc-netty-shaded" % scalapb.compiler.Version.grpcJavaVersion,
      // Logging
      "org.slf4j" % "log4j-over-slf4j" % "2.0.7",
      "org.slf4j" % "slf4j-simple"     % "2.0.7",
      // "ch.qos.logback"        % "logback-classic"      % "1.4.6",
      // Test
      "org.scalameta" %% "munit" % "0.7.29" % Test
    )
  )
  .enablePlugins(NativeImagePlugin)
  .enablePlugins(Fs2Grpc)
