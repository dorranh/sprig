val scala3Version = "3.2.1"

lazy val root = project
  .in(file("."))
  .settings(
    name                                   := "sprig",
    version                                := "0.1.0-SNAPSHOT",
    scalaVersion                           := scala3Version,
    Compile / mainClass                    := Some("dev.appalachian.sprig.server.hello"),
    nativeImageOutput                      := file("artifacts") / "sprig-server",
    libraryDependencies += "org.scalameta" %% "munit" % "0.7.29" % Test
  )
  .enablePlugins(NativeImagePlugin)
