import grpc

from sprig.generated import sprig_pb2
from sprig.generated import sprig_pb2_grpc

from pydantic import BaseModel

import sprig


# # List sprigs
# print(sprig.list(“*”))

# # read a Sprig object
# s = sprig(“mySprigCsvFromS3”)

# # as a file like object, no download requiredwith sprig.open(“”) as f:
#   f.readlines()

# # using pandas sdf = sprig(“mySprigCsvFromS3”).to_df
#  sdf.write_sprig(sprig: Sprig) # if df is a sprig one, can save directly to source sprig, otherwise need to specify a Sprig object


#
#
# read_data :: CallerContext[IO, Sprig] -> <Type for Data?>
#

# CallerContext
#   getContext -> (Metadata on where call is made)
#


class Sprig(BaseModel):
    # This offers methods for IO, a bit similar to a file like object
    _id: UUID

    # Making a request, e.g. read needs to perform a bit of "meta" work to identify its callsite
    # I guess in this case we would want to know the file where the method (e.g. read) is called,
    # however I can imagine there being a number of edge cases (e.g. library functions) where you
    # might want to identify things a bit differently.


class Client:
    pass

    def query():
        # List sprigs
        pass


if __name__ == "__main__":
    with grpc.insecure_channel("localhost:9999") as channel:
        stub = sprig_pb2_grpc.GreeterStub(channel)

        caller_info = sprig_pb2.PythonCallerInfo(
            fileName="my-data-script.py", lineNumber=10
        )
        request = sprig_pb2.GetDataRequest(callerInfo=caller_info)
        response: sprig_pb2.GetDataResponse = stub.GetData(request)
        print("Greeter client received: " + response.foo)
