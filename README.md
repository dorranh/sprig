## sprig

### Usage

This is a normal sbt project. You can compile code with `sbt compile`, run it with `sbt run`, and `sbt console` will start a Scala 3 REPL.

For more information on the sbt-dotty plugin, see the
[scala3-example-project](https://github.com/scala/scala3-example-project/blob/main/README.md).

Generating python protobuf client:

```
python -m grpc_tools.protoc -I=../src/main/protobuf --python_out=sprig/generated ../src/main/protobuf/sprig.proto --pyi_out sprig/generated --grpc_python_out sprig/generated
```