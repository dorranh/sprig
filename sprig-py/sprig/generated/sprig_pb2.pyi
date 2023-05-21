from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class GetDataRequest(_message.Message):
    __slots__ = ["callerInfo"]
    CALLERINFO_FIELD_NUMBER: _ClassVar[int]
    callerInfo: PythonCallerInfo
    def __init__(self, callerInfo: _Optional[_Union[PythonCallerInfo, _Mapping]] = ...) -> None: ...

class GetDataResponse(_message.Message):
    __slots__ = ["foo"]
    FOO_FIELD_NUMBER: _ClassVar[int]
    foo: str
    def __init__(self, foo: _Optional[str] = ...) -> None: ...

class HelloReply(_message.Message):
    __slots__ = ["message"]
    MESSAGE_FIELD_NUMBER: _ClassVar[int]
    message: str
    def __init__(self, message: _Optional[str] = ...) -> None: ...

class HelloRequest(_message.Message):
    __slots__ = ["name"]
    NAME_FIELD_NUMBER: _ClassVar[int]
    name: str
    def __init__(self, name: _Optional[str] = ...) -> None: ...

class PythonCallerInfo(_message.Message):
    __slots__ = ["fileName", "lineNumber"]
    FILENAME_FIELD_NUMBER: _ClassVar[int]
    LINENUMBER_FIELD_NUMBER: _ClassVar[int]
    fileName: str
    lineNumber: int
    def __init__(self, fileName: _Optional[str] = ..., lineNumber: _Optional[int] = ...) -> None: ...
