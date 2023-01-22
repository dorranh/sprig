val scala3Version = "3.2.1"

lazy val root = project
  .in(file("."))
  .settings(
    name         := "sprig",
    version      := "0.1.0-SNAPSHOT",
    scalaVersion := scala3Version,
    // ScalaPB
    Compile / PB.targets := Seq(
      scalapb.gen() -> (Compile / sourceManaged).value / "scalapb"
    ),
    // NativeImage
    Compile / mainClass := Some("dev.appalachian.sprig.server.hello"),
    nativeImageOutput   := file("artifacts") / "sprig-server",
    // Dependencies
    libraryDependencies ++= Seq(
      "io.grpc" % "grpc-netty" % scalapb.compiler.Version.grpcJavaVersion,
      "com.thesamet.scalapb" %% "scalapb-runtime" % scalapb.compiler.Version.scalapbVersion % "protobuf",
      "com.thesamet.scalapb" %% "scalapb-runtime-grpc" % scalapb.compiler.Version.scalapbVersion,
      "org.scalameta"        %% "munit"                % "0.7.29" % Test
    )
  )
  .enablePlugins(NativeImagePlugin)
