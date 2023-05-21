import grpc

from sprig.generated import sprig_pb2
from sprig.generated import sprig_pb2_grpc

if __name__ == "__main__":
    with grpc.insecure_channel("localhost:9999") as channel:
        stub = sprig_pb2_grpc.GreeterStub(channel)

        caller_info = sprig_pb2.PythonCallerInfo(
            fileName="my-data-script.py", lineNumber=10
        )
        request = sprig_pb2.GetDataRequest(callerInfo=caller_info)
        response: sprig_pb2.GetDataResponse = stub.GetData(request)
        print("Greeter client received: " + response.foo)
